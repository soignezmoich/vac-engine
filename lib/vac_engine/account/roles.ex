defmodule VacEngine.Account.Roles do
  import Ecto.Query
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Account.Session
  alias VacEngine.Account.Role
  alias VacEngine.Account.Permissions

  def create_role_multi(type, attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:role, fn _ ->
      %Role{active: true, type: type}
      |> Role.changeset(attrs)
    end)
    |> Multi.merge(fn %{role: role} ->
      Permissions.global_permissions_multi(role)
    end)
  end

  def create_role(type, _attrs) do
    create_role_multi(type)
    |> Repo.transaction()
    |> case do
      {:ok, %{role: role}} -> {:ok, role}
      err -> err
    end
  end

  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  def list_roles(type) do
    from(r in Role, where: r.type == ^type)
    |> Repo.all()
  end

  def activate_role(%Role{} = role) do
    update_role(role, %{"active" => true})
  end

  # TODO signal pub cache to drop API key
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
end
