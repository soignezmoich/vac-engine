defmodule VacEngine.Accounts do
  alias VacEngine.Accounts.Permissions

  defdelegate toggle_permission(user_role, path), to: Permissions
  defdelegate grant_permission(user_role, path), to: Permissions
  defdelegate revoke_permission(user_role, path), to: Permissions
  defdelegate has_permission?(user_role, path), to: Permissions

  alias VacEngine.Accounts.Workspaces

  defdelegate list_workspaces(), to: Workspaces
  defdelegate create_workspace(attrs), to: Workspaces
  defdelegate get_workspace!(id), to: Workspaces

  alias VacEngine.Accounts.Users

  defdelegate list_users(), to: Users
  defdelegate fetch_user(uid), to: Users
  defdelegate check_user(email, password), to: Users
  defdelegate create_user(attrs), to: Users
  defdelegate change_user(data, attrs \\ %{}), to: Users
  defdelegate update_user(data, attrs), to: Users

  alias VacEngine.Accounts.Sessions

  defdelegate fetch_session(token), to: Sessions
  defdelegate get_session!(id), to: Sessions
  defdelegate create_session(role, attrs), to: Sessions
  defdelegate update_session(session, attrs), to: Sessions
  defdelegate revoke_session(session), to: Sessions

  alias VacEngine.Accounts.Roles

  defdelegate update_role(role, attrs), to: Roles
  defdelegate activate_role(role), to: Roles
  defdelegate deactivate_role(role), to: Roles

  alias VacEngine.Accounts.AccessToken

  defdelegate generate_token(length \\ 16), to: AccessToken
end
