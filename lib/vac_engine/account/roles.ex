defmodule VacEngine.Account.Roles do
  @moduledoc false

  import Ecto.Query
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Account.Session
  alias VacEngine.Account.Role
  alias VacEngine.Account.GlobalPermission
  import VacEngine.EctoHelpers, only: [transaction: 2]
  import VacEngine.Pub, only: [bust_api_keys_cache: 0]
  import VacEngine.PipeHelpers

  def list_roles(queries) do
    Role
    |> queries.()
    |> Repo.all()
  end

  def get_role!(id, queries) do
    Role
    |> queries.()
    |> Repo.get!(id)
  end

  def load_role_sessions(query) do
    sessions_query =
      from(s in Session,
        order_by: [desc: s.inserted_at]
      )

    from(r in query,
      preload: [
        :global_permission,
        :workspace_permissions,
        sessions: ^sessions_query
      ]
    )
  end

  def filter_roles_by_type(query, type) do
    from(r in query, where: r.type == ^type)
  end

  def filter_active_roles(query) do
    from(r in query, where: r.active == true)
  end

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
end
