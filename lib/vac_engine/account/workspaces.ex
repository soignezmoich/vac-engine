defmodule VacEngine.Account.Workspaces do
  import Ecto.Query
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Account.Workspace
  alias VacEngine.Account.Role
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Pub.Portal
  import VacEngine.EctoHelpers, only: [transaction: 2]

  def list_workspaces() do
    from(w in Workspace, order_by: :id)
    |> Repo.all()
  end

  def create_workspace(attrs) do
    %Workspace{}
    |> Workspace.changeset(attrs)
    |> Repo.insert()
  end

  def get_workspace!(id) do
    Repo.get!(Workspace, id)
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

  def fetch_workspace(wid) do
    from(w in Workspace,
      where: w.id == ^wid
    )
    |> Repo.one()
    |> case do
      nil -> {:error, "not found"}
      w -> {:ok, w}
    end
  end

  def available_workspaces(%Role{global_permission: %{super_admin: true}}) do
    list_workspaces()
  end

  def available_workspaces(%Role{} = role) do
    from(w in Workspace,
      order_by: :name,
      join: p in assoc(w, :permissions),
      where: p.role_id == ^role.id and p.read == true
    )
    |> Repo.all()
  end
end
