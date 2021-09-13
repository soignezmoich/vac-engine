defmodule VacEngine.Auth.Session do
  use Ecto.Schema
  import Ecto.Changeset
  alias VacEngine.Auth.Role

  schema "sessions" do
    timestamps(type: :utc_datetime)

    belongs_to(:role, Role)

    field(:token, :string)
    field(:expires_at, :utc_datetime)
    field(:last_active_at, :utc_datetime)
    field(:remote_ip, :string)
    field(:client_info, :map)
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:remote_ip, :client_info])
    |> validate_required([:token, :active, :remote_ip])
  end
end
