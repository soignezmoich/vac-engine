defmodule VacEngine.Account.AccessToken do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Role

  schema "access_tokens" do
    timestamps(type: :utc_datetime)

    belongs_to(:role, Role)

    field(:secret, :string)
    field(:type, Ecto.Enum, values: ~w(api_key refresh access link)a)
    field(:expires_at, :utc_datetime)

    field(:test, :boolean, virtual: true)
  end

  @doc false
  def changeset(access_token, attrs \\ %{}) do
    access_token
    |> cast(attrs, [])
    |> validate_required([:type, :secret])
  end
end
