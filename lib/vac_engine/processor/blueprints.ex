defmodule VacEngine.Processor.Blueprints do
  @moduledoc false

  import Ecto.Query
  alias Ecto.Multi
  alias Ecto.Changeset
  alias VacEngine.Repo
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.BindingElement
  alias VacEngine.Processor.Binding
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Deduction
  alias VacEngine.Pub
  alias VacEngine.Hash
  import VacEngine.PipeHelpers

  def create_blueprint(%Workspace{} = workspace, attrs) do
    Multi.new()
    |> multi_create_blueprint(workspace, attrs)
    |> multi_update
  end

  def change_blueprint(%Blueprint{} = blueprint, attrs) do
    blueprint
    |> Blueprint.changeset(attrs)
  end

  def update_blueprint(%Blueprint{} = blueprint, attrs) do
    Multi.new()
    |> multi_update_blueprint(blueprint, attrs)
    |> multi_update
  end

  # TODO what is multi?
  defp multi_update(multi) do
    multi
    |> multi_update_variables
    |> multi_put_variables
    |> multi_update_deductions
    |> multi_put_deductions
    |> multi_compute_hash
    |> multi_put_hash
    |> multi_load_plain
    |> Repo.transaction()
    |> case do
      {:ok, %{{:blueprint, :plain} => br}} ->
        {:ok, br}

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

  defp multi_create_blueprint(multi, workspace, attrs) do
    multi
    |> Multi.put(:workspace, workspace)
    |> Multi.put(:attrs, attrs)
    |> Multi.insert({:blueprint, :base}, fn %{
                                              attrs: attrs,
                                              workspace: workspace
                                            } ->
      %Blueprint{workspace_id: workspace.id}
      |> Blueprint.changeset(attrs)
    end)
    |> Multi.merge(fn %{
                        {:blueprint, :base} => blueprint,
                        workspace: workspace
                      } ->
      Multi.new()
      |> Multi.put(:blueprint_id, blueprint.id)
      |> Multi.put(:workspace_id, workspace.id)
    end)
  end

  defp multi_update_blueprint(multi, blueprint, attrs) do
    multi
    |> Multi.put(:attrs, attrs)
    |> Multi.put(:blueprint_id, blueprint.id)
    |> Multi.put(:workspace_id, blueprint.workspace_id)
    |> Multi.update({:blueprint, :base}, fn %{
                                              attrs: attrs
                                            } ->
      blueprint
      |> Blueprint.changeset(attrs)
    end)
  end

  defp multi_update_variables(multi) do
    multi
    |> Multi.update(
      {:blueprint, :variables},
      fn %{{:blueprint, :base} => blueprint, attrs: attrs} = ctx ->
        blueprint
        |> Repo.preload(:variables)
        |> Blueprint.variables_changeset(attrs, ctx)
      end
    )
  end

  defp multi_put_variables(multi) do
    multi
    |> Multi.merge(fn %{{:blueprint, :variables} => blueprint} ->
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

  defp multi_update_deductions(multi) do
    multi
    |> Multi.update(
      {:blueprint, :deductions},
      fn %{{:blueprint, :variables} => blueprint, attrs: attrs} = ctx ->
        blueprint
        |> Repo.preload(:deductions)
        |> Blueprint.deductions_changeset(attrs, ctx)
      end
    )
  end

  defp multi_put_deductions(multi) do
    multi
    |> Multi.merge(fn %{{:blueprint, :deductions} => blueprint} ->
      Multi.new()
      |> Multi.put(:deductions, blueprint.deductions)
    end)
  end

  defp multi_compute_hash(multi) do
    multi
    |> Multi.run(:compute_hash, fn repo,
                                   %{{:blueprint, :deductions} => blueprint} ->
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

  defp multi_put_hash(multi) do
    multi
    |> Multi.update(
      {:blueprint, :hash},
      fn %{{:blueprint, :deductions} => blueprint, compute_hash: interface_hash} ->
        blueprint
        |> Blueprint.interface_changeset(%{interface_hash: interface_hash})
      end
    )
  end

  defp multi_load_plain(multi) do
    multi
    |> Multi.run({:blueprint, :plain}, fn repo,
                                          %{{:blueprint, :base} => blueprint} ->
      {:ok, repo.get!(Blueprint, blueprint.id)}
    end)
  end

  def get_blueprint!(blueprint_id) do
    Repo.get!(Blueprint, blueprint_id)
  end

  def load_variables(%Blueprint{} = blueprint) do
    Repo.preload(blueprint, [variables: :default], force: true)
    |> arrange_variables()
  end

  def load_deductions(%Blueprint{} = blueprint) do
    elements_query =
      from(r in BindingElement,
        order_by: r.position
      )

    bindings_query =
      from(r in Binding,
        order_by: r.position,
        preload: [
          elements: ^elements_query
        ]
      )

    conditions_query =
      from(r in Condition,
        preload: [
          :column,
          expression: [bindings: ^bindings_query]
        ]
      )

    assignments_query =
      from(r in Assignment,
        preload: [
          :column,
          expression: [bindings: ^bindings_query]
        ]
      )

    branches_query =
      from(r in Branch,
        order_by: r.position,
        preload: [
          conditions: ^conditions_query,
          assignments: ^assignments_query
        ]
      )

    columns_query =
      from(r in Column,
        order_by: r.position,
        preload: [
          expression: [bindings: ^bindings_query]
        ]
      )

    deductions_query =
      from(r in Deduction,
        order_by: r.position,
        preload: [
          branches: ^branches_query,
          columns: ^columns_query
        ]
      )

    Repo.preload(blueprint, [deductions: deductions_query], force: true)
    |> arrange_columns()
    |> arrange_assignments()
    |> arrange_conditions()
  end

  defp arrange_variables(blueprint) do
    {var_tree, path_index} = index_variables(blueprint.variables)

    id_index =
      path_index
      |> Enum.map(fn {_path, var} ->
        {var.id, var}
      end)
      |> Map.new()

    blueprint
    |> put_in([Access.key(:variables)], var_tree)
    |> put_in([Access.key(:variable_path_index)], path_index)
    |> put_in([Access.key(:variable_id_index)], id_index)
  end

  defp arrange_columns(blueprint) do
    blueprint
    |> update_in(
      [
        Access.key(:deductions),
        Access.all(),
        Access.key(:columns),
        Access.all()
      ],
      fn col ->
        Column.insert_bindings(col, blueprint)
      end
    )
  end

  defp arrange_assignments(blueprint) do
    blueprint
    |> update_in(
      [
        Access.key(:deductions),
        Access.all(),
        Access.key(:branches),
        Access.all(),
        Access.key(:assignments),
        Access.all()
      ],
      fn assign ->
        Assignment.insert_bindings(assign, blueprint)
      end
    )
    |> update_in(
      [
        Access.key(:deductions),
        Access.all(),
        Access.key(:branches),
        Access.all(),
        Access.key(:assignments)
      ],
      fn assigns ->
        Enum.sort_by(assigns, fn a ->
          {a.id, a.column && a.column.position}
        end)
      end
    )
  end

  defp arrange_conditions(blueprint) do
    blueprint
    |> update_in(
      [
        Access.key(:deductions),
        Access.all(),
        Access.key(:branches),
        Access.all(),
        Access.key(:conditions),
        Access.all()
      ],
      fn con ->
        Condition.insert_bindings(con, blueprint)
      end
    )
    |> update_in(
      [
        Access.key(:deductions),
        Access.all(),
        Access.key(:branches),
        Access.all(),
        Access.key(:conditions)
      ],
      fn conds ->
        Enum.sort_by(conds, fn a ->
          {a.id, a.column && a.column.position}
        end)
      end
    )
  end

  defp index_variables(variables) do
    by_parent_ids =
      variables
      |> flatten_variables()
      |> Enum.reduce(%{}, fn v, map ->
        vars = Map.get(map, v.parent_id, [])

        Map.put(map, v.parent_id, [v | vars])
      end)

    index_variables(nil, [], by_parent_ids, %{})
  end

  defp index_variables(parent_id, path, by_parent_ids, index) do
    {vars, index} =
      Map.get(by_parent_ids, parent_id)
      |> case do
        nil ->
          {[], index}

        vars ->
          vars
          |> Enum.map_reduce(index, fn v, index ->
            index_variable(v, path, by_parent_ids, index)
          end)
      end

    vars =
      vars
      |> Enum.sort_by(&{&1.mapping, Variable.container?(&1), &1.name})

    {vars, index}
  end

  defp index_variable(var, path, by_parent_ids, index) do
    path = path ++ [var.name]

    {children, index} = index_variables(var.id, path, by_parent_ids, index)

    var = %{var | children: children, path: path}
    {var, Map.put(index, path, var)}
  end

  defp flatten_variables(vars) when not is_list(vars), do: []

  defp flatten_variables(vars) do
    (vars ++ Enum.map(vars, fn var -> flatten_variables(var.children) end))
    |> List.flatten()
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
    |> inspect()
    |> Hash.hash_string()
  end

  def serialize_blueprint(%Blueprint{} = blueprint) do
    blueprint
    |> load_variables
    |> load_deductions
    |> Blueprint.to_map()
  end

  def update_blueprint_from_file(%Blueprint{} = blueprint, path) do
    File.read(path)
    |> case do
      {:ok, json} ->
        Jason.decode(json)
        |> case do
          {:ok, data} ->
            update_blueprint(blueprint, data)

          {:error, _} ->
            {:error, "cannot decode json"}
        end

      {:error, _} ->
        {:error, "cannot read file"}
    end
  end
end
