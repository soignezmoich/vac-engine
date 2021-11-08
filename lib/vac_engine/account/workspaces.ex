defmodule VacEngine.Account.Workspaces do
  @moduledoc false

  import Ecto.Query
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Account.Workspace
  alias VacEngine.Account.Role
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Pub.Portal
  import VacEngine.EctoHelpers, only: [transaction: 2]

  def list_workspaces(queries) do
    Workspace
    |> queries.()
    |> Repo.all()
  end

  def get_workspace!(id, queries) do
    Workspace
    |> queries.()
    |> Repo.get!(id)
  end

  def load_workspace_blueprints(query) do
    from(r in query,
      preload: [
        :blueprints
      ]
    )
  end

  def load_workspace_stats(query) do
    from(r in query,
      left_join: br in assoc(r, :blueprints),
      left_join: pub in assoc(r, :publications),
      on: is_nil(pub.deactivated_at),
      group_by: r.id,
      select_merge: %{
        blueprint_count: count(br.id),
        active_publication_count: count(pub.id)
      }
    )
  end

  def filter_accessible_workspaces(query, %Role{
        global_permission: %{super_admin: true}
      }) do
    query
  end

  def filter_accessible_workspaces(query, %Role{} = role) do
    from(w in query,
      join: p in assoc(w, :permissions),
      where: p.role_id == ^role.id and p.read == true
    )
  end

  def order_workspaces_by(query, key) do
    from(r in query, order_by: field(r, ^key))
  end

  def create_workspace(attrs) do
    %Workspace{}
    |> Workspace.changeset(attrs)
    |> Repo.insert()
  end

  def change_workspace(data, attrs \\ %{}) do
    Workspace.changeset(data, attrs)
  end

  def update_workspace(data, attrs \\ %{}) do
    Workspace.changeset(data, attrs)
    |> Repo.update()
  end

  def delete_workspace(workspace) do
    Multi.new()
    |> Multi.run(:check_blueprints, fn repo, _ ->
      from(r in Blueprint,
        where: r.workspace_id == ^workspace.id,
        select: count(r.id)
      )
      |> repo.one()
      |> case do
        0 -> {:ok, true}
        _ -> {:error, "workspace is not empty, it has blueprints"}
      end
    end)
    |> Multi.run(:check_portals, fn repo, _ ->
      from(r in Portal,
        where: r.workspace_id == ^workspace.id,
        select: count(r.id)
      )
      |> repo.one()
      |> case do
        0 -> {:ok, true}
        _ -> {:error, "workspace is not empty, it has portals"}
      end
    end)
    |> Multi.delete(:delete, workspace)
    |> transaction(:delete)
  end
end
