defmodule VacEngine.Auth do
  alias VacEngine.Repo
  alias VacEngine.Auth.Session
  alias VacEngine.Auth.User
  alias VacEngine.Auth.Role
  alias VacEngine.Token
  alias Ecto.Multi
  import Ecto.Query

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
    |> Repo.insert()
  end

  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  def fetch_user(id) do
    from(u in User, where: u.id == ^id, preload: :role)
    |> Repo.one()
    |> case do
      nil -> {:error, "not found"}
      u -> {:ok, u}
    end
  end

  def check_user(email, password) do
    with user <- Repo.get_by(User, email: email),
         true <- User.check_password(user, password) do
      {:ok, user}
    else
      _ ->
        {:error, "invalid email or password"}
    end
  end

  def create_user(attrs) do
    Multi.new()
    |> Multi.insert(:role, fn _ ->
      %Role{active: true, type: "user"}
      |> Role.changeset(%{})
    end)
    |> Multi.insert(:user, fn %{role: role} ->
      %User{role_id: role.id}
      |> User.changeset(attrs)
    end)
    |> Multi.update(:role_user, fn %{role: role, user: user} ->
      Ecto.Changeset.change(role, user_id: user.id)
    end)
    |> Repo.transaction()
  end
end
