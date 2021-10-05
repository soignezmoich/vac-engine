defmodule VacEngine.Account.Workspaces do
  import Ecto.Query
  alias VacEngine.Repo
  alias VacEngine.Account.Workspace

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
end
