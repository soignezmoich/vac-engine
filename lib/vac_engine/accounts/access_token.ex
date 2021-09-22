defmodule VacEngine.Accounts.AccessToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias VacEngine.Accounts.Role

  schema "access_tokens" do
    timestamps(type: :utc_datetime)

    belongs_to(:role, Role)

    field(:token, :string)
    field(:type, :string)
    field(:expires_at, :utc_datetime)
  end

  @doc false
  def changeset(access_token, attrs) do
    access_token
    |> cast(attrs, [])
    |> validate_required([:type, :token])
  end
end
