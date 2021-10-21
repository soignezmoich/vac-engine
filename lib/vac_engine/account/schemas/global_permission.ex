defmodule VacEngine.Account.GlobalPermission do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Role

  schema "global_permissions" do
    timestamps(type: :utc_datetime)

    belongs_to(:role, Role)

    field(:super_admin, :boolean)
  end

  @doc false
  def changeset(global_permission, attrs \\ %{}) do
    global_permission
    |> cast(attrs, [:super_admin])
  end
end
