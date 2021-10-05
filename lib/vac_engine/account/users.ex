defmodule VacEngine.Account.Users do
  import Ecto.Query
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Account.User
  alias VacEngine.Account.Session
  alias VacEngine.Account.Role
  alias VacEngine.Account.GlobalPermission

  def check_password(nil, _password) do
    Argon2.no_user_verify()
  end

  def check_password(_user, nil) do
    Argon2.no_user_verify()
  end

  def check_password(_user, password) when byte_size(password) > 1024, do: false

  def check_password(%User{} = user, password) do
    Argon2.verify_pass(password, user.encrypted_password)
  end

  def check_user(email, password) do
    with user <-
           from(u in User,
             join: r in assoc(u, :role),
             where: u.email == ^email and r.active == true
           )
           |> Repo.one(),
         true <- check_password(user, password) do
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
      %Role{active: true, type: :user}
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
    |> case do
      {:ok, %{user: user, role: role}} -> {:ok, %{user | role: role}}
      err -> err
    end
  end

  def change_user(data, attrs \\ %{}) do
    User.changeset(data, attrs)
  end

  def update_user(data, attrs \\ %{}) do
    User.changeset(data, attrs)
    |> Repo.update()
  end
end
