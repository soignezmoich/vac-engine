defmodule VacEngine.Accounts.AccessToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias VacEngine.Accounts.Role

  schema "access_tokens" do
    timestamps(type: :utc_datetime)

    belongs_to(:role, Role)

    field(:token, :string)
    field(:type, Ecto.Enum, values: ~w(api_key refresh access)a)
    field(:expires_at, :utc_datetime)
  end

  @doc false
  def changeset(access_token, attrs) do
    access_token
    |> cast(attrs, [])
    |> validate_required([:type, :token])
  end

  def generate_token(length \\ 16) do
    :crypto.strong_rand_bytes(length) |> Base24.encode24()
  end
end
