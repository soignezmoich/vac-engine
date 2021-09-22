defmodule VacEngine.Users do
  alias VacEngine.Repo
  alias VacEngine.Auth.Session
  alias VacEngine.Auth.User
  alias VacEngine.Auth.Role
  alias VacEngine.Auth.GlobalPermission
  alias VacEngine.Token
  alias VacEngine.Permissions
  alias Ecto.Multi
  import Ecto.Query

  def list() do
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

  def fetch(uid) do
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

  def create(attrs) do
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

  def change(data, attrs \\ %{}) do
    User.changeset(data, attrs)
  end

  def update(data, attrs \\ %{}) do
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

      ["workspaces", name, key] ->
        nil
    end
    |> case do
      {:ok, _res} ->
        fetch(user.id)

      err ->
        err
    end
  end
end
