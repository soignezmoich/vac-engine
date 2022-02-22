defmodule VacEngine.Processor.Blueprints.Save do
  @moduledoc false

  import Ecto.Query
  import VacEngine.PipeHelpers
  import VacEngine.Processor.Blueprints.VariableIndex

  alias Ecto.Multi
  alias Ecto.Changeset
  alias VacEngine.EctoHelpers
  alias VacEngine.Account.Workspace
  alias VacEngine.Hash
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Variables
  alias VacEngine.Pub
  alias VacEngine.Repo

  def create_blueprint(%Workspace{} = workspace, attrs) do
    Multi.new()
    |> multi_create_blueprint(workspace, attrs)
    |> multi_update()
  end

  def change_blueprint(%Blueprint{} = blueprint, attrs) do
    blueprint
    |> Blueprint.changeset(attrs)
  end

  def update_blueprint(%Blueprint{} = blueprint, attrs) do
    Multi.new()
    |> multi_update_blueprint(blueprint, attrs)
    |> multi_update()
  end

  defp multi_create_blueprint(multi, workspace, attrs) do
    multi
    |> Multi.put(:workspace, workspace)
    |> Multi.put(:workspace_id, workspace.id)
    |> Multi.put(:attrs, attrs)
    |> Multi.insert(
      :bp_base,
      fn %{attrs: attrs, workspace: workspace} ->
        %Blueprint{workspace_id: workspace.id}
        |> Blueprint.changeset(attrs)
      end
    )
    # |> func_inspect(&(&1 |> Enum.find(fn {a, _} -> a == {:blueprint, :base} end) |> Map.get(:id)),"##### AFTER MULTI UPDATE BLUEPRINT INSPECT #####")
    # |> Multi.inspect()
    |> Multi.merge(fn %{:bp_base => blueprint} ->
      Multi.new()
      |> Multi.put(:blueprint_id, blueprint.id)

      # |> Multi.put(:workspace_id, workspace.id)
    end)
  end

  defp multi_update_blueprint(multi, blueprint, attrs) do
    multi
    |> Multi.put(:attrs, attrs)
    |> Multi.put(:blueprint_id, blueprint.id)
    |> Multi.put(:workspace_id, blueprint.workspace_id)
    |> Multi.update(
      :bp_base,
      fn %{attrs: attrs} ->
        blueprint
        |> Blueprint.changeset(attrs)
      end
    )
  end

  def delete_blueprint(blueprint) do
    Repo.delete(blueprint)
  end

  defp multi_update(multi) do
    multi
    |> multi_inject_variables()
    |> multi_put_variables_context()
    |> multi_inject_variable_defaults()
    |> multi_inject_deductions()
    |> multi_compute_hash()
    |> multi_inject_hash()
    |> multi_inject_simulation()
    |> multi_load_complete_blueprint()
    |> Repo.transaction()
    |> case do
      {:ok, %{:bp_complete => bp}} ->
        {:ok, bp}

      {:error, msg} when is_binary(msg) ->
        {:error, msg}

      {:error, _, msg, _} when is_binary(msg) ->
        {:error, msg}

      {:error, _, %Changeset{} = changeset, _} ->
        {:error, changeset}

      _ ->
        {:error, "cannot save blueprint"}
    end
    |> tap_ok(&Pub.bust_blueprint_cache/1)
  end

  defp multi_inject_variables(multi) do
    multi
    |> Multi.update(
      :bp_after_variables,
      fn %{:bp_base => blueprint, attrs: attrs} = ctx ->
        blueprint
        |> Repo.preload(:variables)
        |> Blueprint.variables_changeset(attrs, ctx)
      end
    )
  end

  defp multi_put_variables_context(multi) do
    multi
    |> Multi.merge(fn %{:bp_after_variables => blueprint} ->
      {variables, path_index} =
        blueprint
        |> Repo.preload(:variables)
        |> Map.get(:variables)
        |> index_variables()

      Multi.new()
      |> Multi.put(:variables, variables)
      |> Multi.put(:variable_path_index, path_index)
    end)
  end

  defp multi_inject_variable_defaults(multi) do
    multi
    |> Multi.merge(fn %{variable_path_index: path_index, attrs: attrs} = ctx ->
      variables =
        attrs
        |> EctoHelpers.accept_array_or_map_for_embed(:variables)
        |> EctoHelpers.get_in_attrs(:variables, [])

      variables
      |> gather_defaults()
      |> Enum.reduce(Multi.new(), fn {path, default}, multi ->
        case Map.fetch(path_index, path) do
          {:ok, variable} ->
            multi
            |> multi_inject_variable_default(variable, default, ctx)

          :error ->
            multi
            |> Multi.error(
              {:variable_default, path},
              "cannot set default, variable #{Enum.join(path, ".")} not found"
            )
        end
      end)
    end)
  end

  defp gather_defaults(variables, stack \\ []) do
    variables
    |> Enum.reduce([], fn var, acc ->
      name = EctoHelpers.get_in_attrs(var, :name)
      default = EctoHelpers.get_in_attrs(var, :default)
      children = EctoHelpers.get_in_attrs(var, :children, [])

      full_name = stack ++ [name]

      acc =
        if default do
          acc ++ [{full_name, default}]
        else
          acc
        end

      children_defaults = gather_defaults(children, full_name)

      acc ++ children_defaults
    end)
  end

  defp multi_inject_variable_default(multi, var, default, ctx) do
    multi
    |> Multi.update({:variable_default, var.id}, fn _ctx ->
      var
      |> Repo.preload(:default)
      |> Variable.update_default_changeset(%{default: default}, ctx)
    end)
    |> Multi.run({:check_default, var.id}, fn repo, ctx ->
      {:ok, var} = Map.fetch(ctx, {:variable_default, var.id})
      Variables.check_default_circular_references(repo, var)
    end)
  end

  defp multi_inject_deductions(multi) do
    multi
    |> Multi.update(
      :bp_after_deductions,
      fn %{:bp_after_variables => blueprint, attrs: attrs} = ctx ->
        blueprint
        |> Repo.preload(:deductions)
        |> Blueprint.deductions_changeset(attrs, ctx)
      end
    )
  end

  defp multi_compute_hash(multi) do
    multi
    |> Multi.run(:compute_hash, fn repo, %{:bp_after_deductions => blueprint} ->
      from(v in Variable,
        where:
          v.blueprint_id == ^blueprint.id and
            fragment("?::text like 'in%'", v.mapping),
        order_by: v.id
      )
      |> repo.all()
      |> variables_interface_hash()
      |> ok()
    end)
  end

  defp multi_inject_hash(multi) do
    multi
    |> Multi.update(
      :bp_after_hash,
      fn %{:bp_after_deductions => blueprint, compute_hash: interface_hash} ->
        blueprint
        |> Blueprint.interface_changeset(%{interface_hash: interface_hash})
      end
    )
  end

  defp multi_inject_simulation(multi) do
    multi
    |> Multi.update(
      :bp_after_simulation,
      fn %{:bp_after_hash => blueprint, attrs: attrs} = ctx ->
        blueprint
        |> Repo.preload([:simulation_setting, :templates, :stacks])
        |> Blueprint.simulation_changeset(attrs, ctx)
      end
    )
  end

  defp multi_load_complete_blueprint(multi) do
    multi
    |> Multi.run(
      :bp_complete,
      fn repo, %{:bp_base => blueprint} ->
        {:ok, repo.get!(Blueprint, blueprint.id)}
      end
    )
  end

  defp variables_interface_hash(vars) do
    vars
    |> Enum.map(fn v ->
      [
        to_string(v.parent_id),
        to_string(v.name),
        to_string(v.type)
      ]
    end)
    |> Hash.hash_string()
  end

  def update_blueprint_from_file(%Blueprint{} = blueprint, path) do
    File.read(path)
    |> case do
      {:ok, json} ->
        Jason.decode(json)
        |> case do
          {:ok, data} ->
            data = Map.put(data, "name", blueprint.name)
            update_blueprint(blueprint, data)

          {:error, _} ->
            {:error, "cannot decode json"}
        end

      {:error, _} ->
        {:error, "cannot read file"}
    end
  end
end
