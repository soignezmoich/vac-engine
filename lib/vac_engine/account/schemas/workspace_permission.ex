defmodule VacEngine.Account.WorkspacePermission do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Account.Role

  schema "workspace_permissions" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:role, Role)

    field(:portals, :map)
    field(:endpoints, :map)
    field(:users, :map)
  end

  @doc false
  def changeset(workspace_permission, attrs \\ %{}) do
    workspace_permission
    |> cast(attrs, [:portals, :endpoints, :users])
    |> validate_required([:portals, :endpoints, :users])
  end
end
