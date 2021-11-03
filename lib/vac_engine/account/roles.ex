defmodule VacEngine.Account.Roles do
  import Ecto.Query
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Account.Session
  alias VacEngine.Account.Role
  alias VacEngine.Account.GlobalPermission
  import VacEngine.EctoHelpers, only: [transaction: 2]
  import VacEngine.Pub, only: [bust_api_keys_cache: 0]
  import VacEngine.PipeHelpers

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
    |> transaction(:role)
  end

  def change_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
  end

  def update_role(%Role{} = role, attrs) do
    Multi.new()
    |> Multi.update(:role, change_role(role, attrs))
    |> transaction(:role)
    |> tap_ok(&bust_api_keys_cache/0)
  end

  def delete_role(%Role{} = role) do
    Multi.new()
    |> Multi.delete(:role, role)
    |> transaction(:role)
    |> tap_ok(&bust_api_keys_cache/0)
  end

  def active_roles(type) do
    from(r in Role, where: r.type == ^type and r.active == true)
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
    |> transaction(:role)
    |> tap_ok(&bust_api_keys_cache/0)
  end

  def load_sessions(%Role{} = role) do
    sessions_query =
      from(s in Session,
        order_by: [desc: s.inserted_at]
      )

    Repo.preload(role, [
      :global_permission,
      :workspace_permissions,
      sessions: sessions_query
    ])
  end
end
