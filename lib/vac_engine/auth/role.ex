defmodule VacEngine.Auth.Role do
  use Ecto.Schema
  import Ecto.Changeset
  alias VacEngine.Auth.Role
  alias VacEngine.Auth.User
  alias VacEngine.Auth.WorkspacePermission
  alias VacEngine.Auth.Session
  alias VacEngine.Auth.GlobalPermission

  schema "roles" do
    timestamps(type: :utc_datetime)

    belongs_to(:user, User)
    belongs_to(:parent, Role)
    has_many(:workspace_permissions, WorkspacePermission)
    has_one(:global_permission, GlobalPermission)

    has_many(:sessions, Session)

    field(:type, :string)
    field(:active, :boolean)
    field(:description, :string)
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:description])
    |> validate_required([:active, :type])
  end
end
