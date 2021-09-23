defmodule VacEngine.Accounts do
  alias VacEngine.Repo
  alias VacEngine.Accounts.Session
  alias VacEngine.Accounts.User
  alias VacEngine.Accounts.Role
  alias VacEngine.Accounts.GlobalPermission
  alias VacEngine.Permissions
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

  def list_users() do
    session_query =
      from(s in Session,
        order_by: [desc: s.inserted_at],
        where: s.role_id == parent_as(:users).role_id,
        limit: 1
      )

    from(u in User,
      as: :users,
      left_lateral_join: s in subquery(session_query),
      order_by: u.id,
      preload: [role: :global_permission],
      select: %{
        u
        | last_login_at: s.inserted_at,
          last_active_at: s.last_active_at
      }
    )
    |> Repo.all()
  end

  def fetch_user(uid) do
    sessions_query =
      from(s in Session,
        order_by: [desc: s.inserted_at]
      )

    from(u in User,
      where: u.id == ^uid,
      preload: [
        role: [
          :global_permission,
          :workspace_permissions,
          sessions: ^sessions_query
        ]
      ]
    )
    |> Repo.one()
    |> case do
      nil -> {:error, "user not found"}
      user -> {:ok, user}
    end
  end

  def create_user(attrs) do
    Multi.new()
    |> Multi.insert(:role, fn _ ->
      %Role{active: true, type: "user"}
      |> Role.changeset(%{})
    end)
    |> Multi.insert(:global_permissions, fn %{role: role} ->
      GlobalPermission.new(role)
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

  def change_user(data, attrs \\ %{}) do
    User.changeset(data, attrs)
  end

  def update_user(data, attrs \\ %{}) do
    User.changeset(data, attrs)
    |> Repo.update()
  end

  def toggle_permission(user, permission_key) do
    String.split(permission_key, ".")
    |> case do
      ["global", name, key] ->
        Permissions.toggle(
          user.role,
          String.to_existing_atom(name),
          String.to_existing_atom(key)
        )

      ["workspaces", _name, _key] ->
        {:error, "not implemented"}
    end
    |> case do
      {:ok, _} -> {:ok, user}
      err -> err
    end
  end
end
