defmodule VacEngine.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Accounts.Role
  alias VacEngine.Accounts.User
  alias VacEngine.Accounts.WorkspacePermission
  alias VacEngine.Accounts.GlobalPermission
  alias VacEngine.Accounts.Session

  schema "roles" do
    timestamps(type: :utc_datetime)

    belongs_to(:user, User)
    belongs_to(:parent, Role)
    has_many(:workspace_permissions, WorkspacePermission)
    has_one(:global_permission, GlobalPermission)

    has_many(:sessions, Session)

    field(:type, Ecto.Enum, values: ~w(user link api)a)
    field(:active, :boolean)
    field(:description, :string)
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:description, :active])
    |> validate_required([:active, :type])
  end
end