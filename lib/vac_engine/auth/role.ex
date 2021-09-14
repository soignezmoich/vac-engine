defmodule VacEngine.Auth.Role do
  use Ecto.Schema
  import Ecto.Changeset
  alias VacEngine.Auth.Role
  alias VacEngine.Auth.User

  schema "roles" do
    timestamps(type: :utc_datetime)

    belongs_to(:user, User)
    belongs_to(:parent, Role)

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
