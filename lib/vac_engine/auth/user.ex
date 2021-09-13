defmodule VacEngine.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    timestamps(type: :utc_datetime)

    field(:name, :string)
    field(:description, :string)
    field(:email, :string)
    field(:phone, :string)
    field(:encrypted_password, :string)
    field(:totp_secret, :string)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :description, :phone])
    |> validate_required([:name])
  end
end
