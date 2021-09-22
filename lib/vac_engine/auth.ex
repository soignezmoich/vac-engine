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
    %Session{role_id: role.id, token: Token.generate()}
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

  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  def activate_role(%Role{} = role) do
    update_role(role, %{"active" => true})
  end

  def deactivate_role(%Role{} = role) do
    Multi.new()
    |> Multi.update(:role, fn _ ->
      Role.changeset(role, %{"active" => false})
    end)
    |> Multi.update_all(
      :sessions,
      fn %{role: role} ->
        exp = NaiveDateTime.utc_now() |> NaiveDateTime.add(-1)

        from(s in Session,
          where: s.role_id == ^role.id,
          update: [set: [expires_at: ^exp]]
        )
      end,
      []
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{role: role}} -> {:ok, role}
      err -> err
    end
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
    with user <-
           from(u in User,
             join: r in assoc(u, :role),
             where: u.email == ^email and r.active == true
           )
           |> Repo.one(),
         true <- User.check_password(user, password) do
      {:ok, user}
    else
      _ ->
        {:error, "invalid email or password"}
    end
  end
end
