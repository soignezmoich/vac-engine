defmodule VacEngine.Auth do
  alias VacEngine.Repo
  alias VacEngine.Auth.Session
  alias VacEngine.Auth.User
  alias VacEngine.Auth.Role
  alias VacEngine.Token

  def fetch_session(token)

  def fetch_session(token) when not is_binary(token) do
    {:error, "session token must be a string"}
  end

  def fetch_session(token) do
    Repo.get_by(Session, token: token)
    |> case do
      nil -> {:error, "session token not found"}
      session -> {:ok, session}
    end
  end

  def create_session(%Role{} = role, attrs) do
    %Session{role_id: role.id, token: Token.generate()}
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  def get_user(id), do: Repo.get(User, id)

  def check_user(email, password) do
    with user <- Repo.get_by(User, email: email),
         true <- User.check_password(user, password) do
      {:ok, user}
    else
      _ ->
        {:error, "invalid email or password"}
    end
  end
end
