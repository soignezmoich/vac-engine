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
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.Template

  def create_blueprint(%Workspace{} = workspace, attrs) do
    base_attrs = attrs |> Map.take([:name, "name"])

    Multi.new()
    |> Multi.put(:attrs, attrs)
    |> multi_create_blueprint(base_attrs, attrs, workspace.id)
    |> multi_inject()
  end

  def update_blueprint(%Blueprint{} = blueprint, attrs) do
    Multi.new()
    |> Multi.put(:attrs, attrs)
    |> multi_update_blueprint(blueprint)
    |> multi_inject()
  end

  defp multi_create_blueprint(multi, base_attrs, attrs, workspace_id) do
    multi
    |> Multi.insert(
      :bp_base,
      fn %{} ->
        %Blueprint{workspace_id: workspace_id}
        # split between base_attrs and attrs is necessary
        # due to possible mix of string and atom keys
        |> Blueprint.changeset(base_attrs)
        |> Blueprint.changeset(attrs)
      end
    )
  end

  defp multi_update_blueprint(multi, blueprint) do
    multi
    |> Multi.update(
      :bp_base,
      fn %{attrs: attrs} -> Blueprint.changeset(blueprint, attrs) end
    )
  end

  def delete_blueprint(%Blueprint{} = blueprint) do
    Multi.new()
    |> multi_delete_blueprint(blueprint)
    |> Repo.transaction()
  end

  defp multi_delete_blueprint(multi, %Blueprint{} = blueprint) do
    # The structure below (gather_orphaned_cases -> delete_blueprint -> delete_orphaned_cases) result
    # from the following facts:
    # - Cases can only be deleted if not referenced by a layer (or template), so the blueprint
    #   deletion must occur case deletion.
    # - The cases to delete can be retrieved more efficiently by using the stack and layers. So
    #   the orphaned cases retrieval must occur before blueprint deletion.

    multi
    |> gather_orphaned_cases_multi(blueprint)
    |> Multi.delete(:delete_blueprint, blueprint)
    |> Multi.delete_all(
      :delete_orphaned_cases,
      fn %{gather_orphaned_cases: orphaned_cases_ids} ->
        from(c in Case, where: c.id in ^orphaned_cases_ids)
      end
    )
  end

  defp gather_orphaned_cases_multi(multi, blueprint) do
    multi
    |> Multi.run(:gather_orphaned_cases, fn repo, _ ->
      linked_to_blueprint_by_layer =
        from(c in Case,
          join: l in Layer,
          on: l.case_id == c.id and l.blueprint_id == ^blueprint.id,
          select: c.id
        )

      linked_to_blueprint_by_layer_or_template =
        from(c in Case,
          join: t in Template,
          on: t.case_id == c.id and t.blueprint_id == ^blueprint.id,
          select: c.id,
          union: ^linked_to_blueprint_by_layer
        )

      linked_only_to_blueprint =
        from(c in subquery(linked_to_blueprint_by_layer_or_template),
          left_join: l1 in Layer,
          on: l1.case_id == c.id and l1.blueprint_id != ^blueprint.id,
          left_join: t1 in Template,
          on: t1.case_id == c.id and t1.blueprint_id != ^blueprint.id,
          where: is_nil(l1.id) and is_nil(t1.id),
          select: c.id
        )

      linked_only_to_blueprint
      |> repo.all()
      |> ok()
    end)
  end

  defp multi_inject(multi) do
    multi
    |> multi_put_blueprint_and_workspace_ids()
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
      {:ok, %{bp_complete: bp}} -> {:ok, bp}
      {:error, msg} when is_binary(msg) -> {:error, msg}
      {:error, _, msg, _} when is_binary(msg) -> {:error, msg}
      {:error, _, %Changeset{} = changeset, _} -> {:error, changeset}
      _ -> {:error, "cannot save blueprint"}
    end
    |> tap_ok(&Pub.bust_blueprint_cache/1)
  end

  defp multi_put_blueprint_and_workspace_ids(multi) do
    multi
    |> Multi.run(:blueprint_id, fn _repo, %{bp_base: blueprint} ->
      {:ok, blueprint.id}
    end)
    |> Multi.run(:workspace_id, fn _repo, %{bp_base: blueprint} ->
      {:ok, blueprint.workspace_id}
    end)
  end

  defp multi_inject_variables(multi) do
    multi
    |> Multi.update(
      :bp_after_variables,
      fn %{bp_base: blueprint, attrs: attrs} = ctx ->
        blueprint
        |> Repo.preload(:variables)
        |> Blueprint.variables_changeset(attrs, ctx)
      end
    )
  end

  defp multi_put_variables_context(multi) do
    multi
    |> Multi.merge(fn %{bp_after_variables: blueprint} ->
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
      fn %{bp_after_variables: blueprint, attrs: attrs} = ctx ->
        blueprint
        |> Repo.preload(:deductions)
        |> Blueprint.deductions_changeset(attrs, ctx)
      end
    )
  end

  defp multi_compute_hash(multi) do
    multi
    |> Multi.run(:compute_hash, fn repo, %{bp_after_deductions: blueprint} ->
      from(v in Variable,
        # Only consider input variables for hash
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
      fn %{bp_after_deductions: blueprint, compute_hash: interface_hash} ->
        blueprint
        |> Blueprint.interface_changeset(%{interface_hash: interface_hash})
      end
    )
  end

  defp multi_inject_simulation(multi) do
    multi
    |> Multi.update(
      :bp_after_simulation,
      fn %{bp_after_hash: blueprint, attrs: attrs} = ctx ->
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
      fn repo, %{bp_base: blueprint} ->
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

  def update_blueprint_from_file(%Workspace{} = workspace, path) do
    File.read(path)
    |> case do
      {:ok, json} ->
        Jason.decode(json)
        |> case do
          {:ok, data} ->
            create_blueprint(workspace, data)

          {:error, _} ->
            {:error, "cannot decode json"}
        end

      {:error, _} ->
        {:error, "cannot read file"}
    end
  end
end
