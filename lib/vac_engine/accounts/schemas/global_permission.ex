defmodule VacEngine.Accounts.GlobalPermission do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Accounts.Role
  alias VacEngine.Accounts.PermissionsType

  schema "global_permissions" do
    timestamps(type: :utc_datetime)

    belongs_to(:role, Role)

    field(:workspaces, PermissionsType)
    field(:users, PermissionsType)
  end

  def new(role) do
    %__MODULE__{
      role_id: role.id,
      users: %PermissionsType{},
      workspaces: %PermissionsType{}
    }
  end

  @doc false
  def changeset(global_permission, attrs) do
    global_permission
    |> cast(attrs, [:workspaces, :users])
    |> validate_required([:workspaces, :users])
  end
end
