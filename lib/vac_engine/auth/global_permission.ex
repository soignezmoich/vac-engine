defmodule VacEngine.Auth.GlobalPermission do
  use Ecto.Schema
  import Ecto.Changeset
  alias VacEngine.Auth.Role

  schema "global_permissions" do
    timestamps(type: :utc_datetime)

    belongs_to(:role, Role)

    field(:workspaces, :map)
    field(:users, :map)
  end

  @doc false
  def changeset(global_permission, attrs) do
    global_permission
    |> cast(attrs, [:workspaces, :users])
    |> validate_required([:workspaces, :users])
  end
end
