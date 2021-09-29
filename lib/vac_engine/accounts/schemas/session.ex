defmodule VacEngine.Accounts.Session do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Accounts.Role
  alias VacEngine.Accounts.Session

  schema "sessions" do
    timestamps(type: :utc_datetime)

    belongs_to(:role, Role)

    field(:token, :string)
    field(:expires_at, :utc_datetime)
    field(:last_active_at, :utc_datetime)
    field(:remote_ip, EctoNetwork.INET)
    field(:client_info, :map)
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:remote_ip, :client_info, :last_active_at, :expires_at])
    |> validate_required([:token, :remote_ip])
  end

  def expired?(%Session{expires_at: nil}), do: false

  def expired?(%Session{expires_at: ts}) do
    NaiveDateTime.compare(ts, NaiveDateTime.utc_now()) != :gt
  end
end
