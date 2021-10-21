defmodule VacEngine.Account do
  alias VacEngine.Account.Permissions

  defdelegate toggle_permission(role, action, scope), to: Permissions
  defdelegate toggle_permission(role, action), to: Permissions
  defdelegate grant_permission(role, action, scope), to: Permissions
  defdelegate grant_permission(role, action), to: Permissions
  defdelegate revoke_permission(role, action, scope), to: Permissions
  defdelegate revoke_permission(role, action), to: Permissions
  defdelegate has_permission?(role, action, scope), to: Permissions
  defdelegate has_permission?(role, action), to: Permissions

  alias VacEngine.Account.Policy

  defdelegate can?(role, action, scope), to: Policy
  defdelegate can?(role, action), to: Policy

  alias VacEngine.Account.Workspaces

  defdelegate list_workspaces(), to: Workspaces
  defdelegate create_workspace(attrs), to: Workspaces
  defdelegate get_workspace!(id), to: Workspaces

  alias VacEngine.Account.Users

  defdelegate list_users(), to: Users
  defdelegate fetch_user(uid), to: Users
  defdelegate check_user(email, password), to: Users
  defdelegate create_user(attrs), to: Users
  defdelegate change_user(data, attrs \\ %{}), to: Users
  defdelegate update_user(data, attrs), to: Users

  alias VacEngine.Account.Sessions

  defdelegate fetch_session(token), to: Sessions
  defdelegate get_session!(id), to: Sessions
  defdelegate create_session(role, attrs), to: Sessions
  defdelegate update_session(session, attrs), to: Sessions
  defdelegate revoke_session(session), to: Sessions

  alias VacEngine.Account.Roles

  defdelegate create_role(type, attrs \\ %{}), to: Roles
  defdelegate update_role(role, attrs), to: Roles
  defdelegate activate_role(role), to: Roles
  defdelegate deactivate_role(role), to: Roles

  alias VacEngine.Account.AccessTokens

  defdelegate generate_secret(length \\ 16), to: AccessTokens
  defdelegate create_api_token(role), to: AccessTokens

  defdelegate generate_composite_secret(prefix, id), to: AccessTokens
  defdelegate explode_composite_secret(secret), to: AccessTokens

  alias VacEngine.Pub

  def list_api_keys() do
    # TODO actually check role portal id permissions
    portals =
      Pub.list_portals()
      |> Enum.map(fn portal ->
        portal
        |> Pub.active_publication()
        |> case do
          nil ->
            nil

          publi ->
            {portal.id, %{blueprint_id: publi.blueprint_id}}
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Map.new()

    Roles.list_roles(:api)
    |> Enum.map(fn r ->
      AccessTokens.list_api_tokens(r)
      |> Enum.map(fn t ->
        %{secret: t.secret, portals: portals}
      end)
    end)
    |> List.flatten()
  end
end
