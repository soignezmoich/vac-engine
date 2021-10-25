defmodule VacEngine.Account.Roles do
  import Ecto.Query
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Account.Session
  alias VacEngine.Account.Role
  alias VacEngine.Account.GlobalPermission
  alias VacEngine.Pub

  def create_role_multi(type, attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:role, fn _ ->
      %Role{active: true, type: type}
      |> Role.changeset(attrs)
    end)
    |> Multi.insert(:global_permissions, fn %{role: role} ->
      %GlobalPermission{role_id: role.id}
    end)
  end

  def create_role(type, attrs) do
    create_role_multi(type, attrs)
    |> Repo.transaction()
    |> case do
      {:ok, %{role: role}} -> {:ok, role}
      {:error, _, err, _} -> {:error, err}
    end
  end

  def change_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
  end

  def update_role(%Role{} = role, attrs) do
    role
    |> change_role(attrs)
    |> Repo.update()
  end

  def delete_role(%Role{} = role) do
    role
    |> Repo.delete()
  end

  def list_roles(type) do
    from(r in Role, where: r.type == ^type)
    |> Repo.all()
  end

  def get_role!(id) do
    Repo.get!(Role, id)
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
    |> Multi.run(:refresh_cache, fn _repo, _ctx ->
      Pub.refresh_cache_api_keys()
      |> case do
        :ok -> {:ok, nil}
        _ -> {:error, "cannot refresh cache"}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{role: role}} -> {:ok, role}
      err -> err
    end
  end
end
