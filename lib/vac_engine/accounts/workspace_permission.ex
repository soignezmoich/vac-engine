defmodule VacEngine.Accounts.WorkspacePermission do
  use Ecto.Schema
  import Ecto.Changeset
  alias VacEngine.Accounts.Workspace
  alias VacEngine.Accounts.Role

  schema "workspace_permissions" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:role, Role)

    field(:portals, :map)
    field(:endpoints, :map)
    field(:users, :map)
  end

  @doc false
  def changeset(workspace_permission, attrs) do
    workspace_permission
    |> cast(attrs, [:portals, :endpoints, :users])
    |> validate_required([:portals, :endpoints, :users])
  end
end
