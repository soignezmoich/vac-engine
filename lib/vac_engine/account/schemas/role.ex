defmodule VacEngine.Account.Role do
  @moduledoc """
  A role is the representation of a actor (user, api request...)
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Role
  alias VacEngine.Account.User
  alias VacEngine.Account.WorkspacePermission
  alias VacEngine.Account.GlobalPermission
  alias VacEngine.Account.Session
  alias VacEngine.Account.AccessToken

  schema "roles" do
    timestamps(type: :utc_datetime)

    belongs_to(:user, User)
    belongs_to(:parent, Role)
    has_many(:workspace_permissions, WorkspacePermission)
    has_one(:global_permission, GlobalPermission)

    has_many(:sessions, Session)
    has_many(:access_tokens, AccessToken)

    field(:type, Ecto.Enum, values: ~w(user link api)a)
    field(:active, :boolean)
    field(:description, :string)

    has_many(:api_tokens, AccessToken)
  end

  @doc false
  def changeset(role, attrs \\ %{}) do
    role
    |> cast(attrs, [:description, :active])
    |> validate_required([:type])
  end
end
