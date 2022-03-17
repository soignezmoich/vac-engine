defmodule VacEngine.Processor.Blueprints.Load do
  @moduledoc false

  import Ecto.Query
  import VacEngine.Processor.Blueprints.Arrange

  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Account.WorkspacePermission
  alias VacEngine.Account.Role
  alias VacEngine.Account.BlueprintPermission
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.BindingElement
  alias VacEngine.Processor.Binding
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Deduction
  alias VacEngine.Pub.Publication

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

  def load_blueprint_workspace(query) do
    from(b in query, preload: :workspace)
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

    from(b in query,
      preload: [variables: [default: [bindings: ^bindings_query]]]
    )
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

  def load_blueprint_simulation(query, with_cases? \\ false) do
    query
    |> preload(:simulation_setting)
    |> with_stacks(with_cases?: with_cases?)
    |> with_templates(with_cases?: with_cases?)
  end

  defp with_stacks(query, with_cases?: true) do
    query
    |> preload(stacks: [layers: [case: [:input_entries, :output_entries]]])
  end

  defp with_stacks(query, _) do
    query
    |> preload(stacks: :layers)
  end

  defp with_templates(query, with_cases?: true) do
    query
    |> preload(templates: [case: [:input_entries, :output_entries]])
  end

  defp with_templates(query, _) do
    query
    |> preload(:templates)
  end

  def get_full_blueprint!(blueprint_id, with_cases?) do
    get_blueprint!(blueprint_id, fn query ->
      query
      |> load_blueprint_variables()
      |> load_blueprint_full_deductions()
      |> load_blueprint_simulation(with_cases?)
    end)
  end

  def serialize_blueprint(%Blueprint{} = blueprint) do
    blueprint
    |> Blueprint.to_map()
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
