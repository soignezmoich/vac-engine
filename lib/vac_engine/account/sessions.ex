defmodule VacEngine.Account.Sessions do
  import Ecto.Query
  alias VacEngine.Repo
  alias VacEngine.Account
  alias VacEngine.Account.Session
  alias VacEngine.Account.Role

  def fetch_session(token)

  def fetch_session(token) when not is_binary(token) do
    {:error, "session token must be a string"}
  end

  def fetch_session(token) do
    from(r in Session,
      where:
        r.token == ^token and
          (r.expires_at >
             fragment("timezone('UTC', now())") or is_nil(r.expires_at)),
      preload: [role: [:global_permission, :workspace_permissions]]
    )
    |> Repo.one()
    |> case do
      nil -> {:error, "session token not found"}
      session -> {:ok, session}
    end
  end

  def get_session!(id) do
    Repo.get!(Session, id)
  end

  def create_session(%Role{} = role, attrs) do
    %Session{role_id: role.id, token: Account.generate_secret()}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  def revoke_session(%Session{} = session) do
    session
    |> update_session(%{
      "expires_at" => NaiveDateTime.utc_now() |> NaiveDateTime.add(-1)
    })
  end
end
