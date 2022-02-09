defmodule VacEngine.Processor.Blueprints do
  @moduledoc false

  import Ecto.Query
  alias Ecto.Multi
  alias Ecto.Changeset
  alias VacEngine.Repo
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Account.Workspace
  alias VacEngine.Account.WorkspacePermission
  alias VacEngine.Account.Role
  alias VacEngine.Account.BlueprintPermission
  alias VacEngine.Hash
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.BindingElement
  alias VacEngine.Processor.Binding
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Deduction
  alias VacEngine.Pub
  alias VacEngine.Pub.Publication
  import VacEngine.PipeHelpers

  def list_blueprints(queries) do
    Blueprint
    |> queries.()
    |> Repo.all()
    |> Enum.map(&arrange_all/1)
  end

  def get_blueprint!(blueprint_id, queries) do
    Blueprint
    |> queries.()
    |> Repo.get!(blueprint_id)
    |> arrange_all()
  end

  def get_blueprint(blueprint_id, queries) do
    Blueprint
    |> queries.()
    |> Repo.get(blueprint_id)
    |> arrange_all()
  end

  def filter_blueprints_by_workspace(query, workspace) do
    from(b in query, where: b.workspace_id == ^workspace.id)
  end

  def filter_accessible_blueprints(query, %Role{
        global_permission: %{super_admin: true}
      }) do
    query
  end

  def filter_accessible_blueprints(query, role) do
    workspace_permissions =
      from(p in WorkspacePermission,
        where: p.role_id == ^role.id and p.read_blueprints == true,
        select: p.workspace_id
      )

    blueprint_permissions =
      from(p in BlueprintPermission,
        where: p.role_id == ^role.id and p.read == true,
        select: p.blueprint_id
      )

    from(b in query,
      where:
        b.workspace_id in subquery(workspace_permissions) or
          b.id in subquery(blueprint_permissions)
    )
  end

  def load_blueprint_active_publications(query) do
    pub_query =
      from(r in Publication,
        order_by: [desc: r.activated_at],
        where: is_nil(r.deactivated_at),
        preload: :portal
      )

    from(b in query, preload: [active_publications: ^pub_query])
  end

  def load_blueprint_inactive_publications(query) do
    pub_query =
      from(r in Publication,
        order_by: [desc: r.activated_at],
        where: not is_nil(r.deactivated_at),
        preload: :portal
      )

    from(b in query, preload: [inactive_publications: ^pub_query])
  end

  def load_blueprint_publications(query) do
    pub_query =
      from(r in Publication,
        order_by: [desc: r.deactivated_at, desc: r.activated_at],
        preload: :portal
      )

    from(b in query, preload: [publications: ^pub_query])
  end

  def load_blueprint_variables(query) do
    from(b in query, preload: [variables: :default])
  end

  def load_blueprint_full_deductions(query) do
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

    from(b in query, preload: [deductions: ^deductions_query])
  end

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

  def delete_blueprint(blueprint) do
    Repo.delete(blueprint)
  end

  def duplicate_blueprint(blueprint_id, workspace)
      when is_integer(blueprint_id) do
    try do
      get_full_blueprint!(blueprint_id)
      |> serialize_blueprint()
      |> duplicate_from_serialized!(workspace)
    catch
      error -> error
    end
  end

  defp get_full_blueprint!(blueprint_id) do
    get_blueprint!(blueprint_id, fn query ->
      query
      |> load_blueprint_variables()
      |> load_blueprint_full_deductions()
    end)
  end

  # TODO add stacks and templates to get_full_blueprint
  # TODO make a version including cases for export purpose

  defp duplicate_from_serialized!(%{} = serialized_blueprint, workspace) do
    {:ok, new_blueprint} = create_blueprint(workspace, serialized_blueprint)

    {:ok, renamed_blueprint} =
      update_blueprint(new_blueprint, %{
        "name" => "copy of #{serialized_blueprint.name}"
      })

    renamed_blueprint
  end

  def blueprint_readonly?(%Blueprint{publications: []}), do: false

  def blueprint_readonly?(%Blueprint{publications: publications})
      when is_list(publications),
      do: true

  def blueprint_readonly?(blueprint) do
    from(p in Publication,
      where: p.blueprint_id == ^blueprint.id,
      limit: 1
    )
    |> Repo.exists?()
  end

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

  defp arrange_all(nil), do: nil

  defp arrange_all(blueprint) do
    blueprint
    |> arrange_variables()
    |> arrange_columns()
    |> arrange_assignments()
    |> arrange_conditions()
  end

  defp arrange_variables(
         %Blueprint{variables: %Ecto.Association.NotLoaded{}} = br
       ) do
    br
  end

  defp arrange_variables(blueprint) do
    {var_tree, path_index} = index_variables(blueprint.variables)

    id_index =
      path_index
      |> Enum.map(fn {_path, var} ->
        {var.id, var}
      end)
      |> Map.new()

    {input_variables, output_variables, intermediate_variables} =
      blueprint.variables
      |> Enum.map(fn var -> Map.get(id_index, var.id) end)
      |> Enum.sort_by(fn var -> var.path end)
      |> Enum.reduce({[], [], []}, fn var, {inp, out, rest} ->
        inp =
          if Variable.input?(var) do
            [var | inp]
          else
            inp
          end

        out =
          if Variable.output?(var) do
            [var | out]
          else
            out
          end

        rest =
          if !Variable.input?(var) and !Variable.output?(var) do
            [var | rest]
          else
            rest
          end

        {inp, out, rest}
      end)
      |> Tuple.to_list()
      |> Enum.map(&Enum.reverse/1)
      |> List.to_tuple()

    %{
      blueprint
      | variables: var_tree,
        variable_path_index: path_index,
        variable_id_index: id_index,
        input_variables: input_variables,
        output_variables: output_variables,
        intermediate_variables: intermediate_variables
    }
  end

  defp arrange_columns(
         %Blueprint{deductions: %Ecto.Association.NotLoaded{}} = br
       ) do
    br
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

  defp arrange_assignments(
         %Blueprint{deductions: %Ecto.Association.NotLoaded{}} = br
       ) do
    br
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

  defp arrange_conditions(
         %Blueprint{deductions: %Ecto.Association.NotLoaded{}} = br
       ) do
    br
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
    |> Blueprint.to_map()
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

  def blueprint_version(%Blueprint{id: id}) do
    blueprint_version(id)
  end

  def blueprint_version(id) do
    Multi.new()
    |> Multi.run(:blueprint, fn repo, _ ->
      from(b in Blueprint,
        where: b.id == ^id,
        order_by: [desc: b.updated_at],
        limit: 1,
        select: b.updated_at
      )
      |> repo.one()
      |> case do
        nil -> {:error, nil}
        date -> {:ok, Timex.to_unix(date)}
      end
    end)
    |> Multi.run(:deduction, fn repo, _ ->
      get_latest(id, repo, Deduction)
    end)
    |> Multi.run(:branch, fn repo, _ ->
      get_latest(id, repo, Branch)
    end)
    |> Multi.run(:condition, fn repo, _ ->
      get_latest(id, repo, Condition)
    end)
    |> Multi.run(:assignment, fn repo, _ ->
      get_latest(id, repo, Assignment)
    end)
    |> Multi.run(:variable, fn repo, _ ->
      get_latest(id, repo, Variable)
    end)
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         assignment: a,
         blueprint: b,
         branch: c,
         condition: d,
         deduction: e,
         variable: f
       }} ->
        for(i <- [a, b, c, d, e, f], do: <<i::64>>, into: <<>>)
        |> then(fn a ->
          :crypto.hash(:md5, a)
        end)
        |> :binary.decode_unsigned()

      _ ->
        nil
    end
  end

  defp get_latest(blueprint_id, repo, mod) do
    from(r in mod,
      where: r.blueprint_id == ^blueprint_id,
      order_by: [desc: r.updated_at],
      limit: 1,
      select: r.updated_at
    )
    |> repo.one()
    |> case do
      nil -> {:ok, 0}
      date -> {:ok, Timex.to_unix(date)}
    end
  end
end
