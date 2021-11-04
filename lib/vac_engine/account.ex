defmodule VacEngine.Account do
  @moduledoc """
  ## Account Module
  The Account module is responsible for the management
  of a role-based permission system.

  ### Structure
  The entities involved in this system are:
  #### roles
  Roles are primary entities to which permissions can be attached.
  #### users
  Extension to a role that links it to a login/password/MFA identifier.
  #### api-keys
  Extension to a role that links it to an api-key identifier.
  #### tokens
  Tokens, embedded in a url/link that correspond to a role. (?)
  #### permissions
  Relation between role and action in a given scope that allows
  the role to perform the given action in the given scope.
   --> WHAT IS KEY???
  #### actions
  An action that can be allowed or not, it usually materialize
  in a piece of code preceded by a call to can?/3 function.
  #### scope
  A context that can influence the permission to certain actions,
  for example a workspace.
  #### workspaces
  A bundle of blueprints and portals to which roles can be granted access
  or not as a bundle.
  #### sessions
  Scope of time in which a role is granted following an identification.
  #### secrets
  (???)

  ### Specific security aspects (maybe move to README?)
  The Account module implements the following principe in order
  to ensure security of the system:
  * Users are authenticated using MFA (login/password + authentication).
  * Treatment of wrong login/password pairs are treated in constant time.
  * Sessions linked to role of all types (api-keys, users, tokens)
    can be revocated by admin at any time.
  * Only admins have the right to publish a blueprint on a portal so that
    no simple editor can influence the behaviour of the api.
  """

  alias VacEngine.Account.Permissions

  @doc """
  Toggle permission with an action and scope
  """
  defdelegate toggle_permission(role, action, scope \\ :global),
    to: Permissions

  @doc """
  Grant permission with an action and scope
  """
  defdelegate grant_permission(role, action, scope \\ :global),
    to: Permissions

  @doc """
  Revoke permission with an action and scope
  """
  defdelegate revoke_permission(role, action, scope \\ :global),
    to: Permissions

  alias VacEngine.Account.Can

  @doc """
  Check action against role with scope.
  """
  defdelegate can?(role, action, scope \\ :global), to: Can

  alias VacEngine.Account.Workspaces

  @doc """
  List all workspaces
  """
  defdelegate list_workspaces(), to: Workspaces

  @doc """
  Get a workspace with id, raise if not found.
  """
  defdelegate get_workspace!(id), to: Workspaces

  @doc """
  Create a workspace with attributes
  """
  defdelegate create_workspace(attrs), to: Workspaces

  @doc """
  Return all available workspaces for a given role
  """
  defdelegate available_workspaces(role), to: Workspaces

  @doc """
  Cast attributes into a changeset
  """
  defdelegate change_workspace(data, attrs \\ %{}), to: Workspaces

  @doc """
  Update workspace with attributes
  """
  defdelegate update_workspace(data, attrs), to: Workspaces

  @doc """
  Delete workspace.

  This will fail is the workspace has any blueprint or portal
  """
  defdelegate delete_workspace(data), to: Workspaces

  @doc """
  Load blueprints assoc
  """
  defdelegate load_blueprints(workspace), to: Workspaces

  alias VacEngine.Account.Users

  @doc """
  Return all users with `last_login_at` and `last_active_at` virtual fields
  populated
  """
  defdelegate list_users(), to: Users

  @doc """
  Get a user with id, raise if not found.
  """
  defdelegate get_user!(uid), to: Users

  @doc """
  Check a email/password and return the user if both are valid (used for login)

  If the password is nil or wrong or the user not found, the time for the check
  will be constant.
  """
  defdelegate check_user(email, password), to: Users

  @doc """
  Create a user with attributes

  This will also create the "role" for the user and set it as active
  """
  defdelegate create_user(attrs), to: Users

  @doc """
  Cast attributes into a changeset
  """
  defdelegate change_user(data, attrs \\ %{}), to: Users

  @doc """
  Update user with attributes
  """
  defdelegate update_user(data, attrs), to: Users

  @doc """
  Load role assoc
  """
  defdelegate load_role(user), to: Users

  alias VacEngine.Account.Sessions

  @doc """
  Try to find a session with given token
  """
  defdelegate fetch_session(token), to: Sessions

  @doc """
  Get a session with id, raise if not found.
  """
  defdelegate get_session!(id), to: Sessions

  @doc """
  Create a session with attributes
  """
  defdelegate create_session(role, attrs), to: Sessions

  @doc """
  Update session with attributes
  """
  defdelegate update_session(session, attrs), to: Sessions

  @doc """
  Revoke session
  """
  defdelegate revoke_session(session), to: Sessions

  alias VacEngine.Account.Roles

  @doc """
  Get a role with id, raise if not found.
  """
  defdelegate get_role!(id), to: Roles

  @doc """
  Create a role with attributes
  """
  defdelegate create_role(type, attrs \\ %{}), to: Roles

  @doc """
  Update role with attributes
  """
  defdelegate update_role(role, attrs \\ %{}), to: Roles

  @doc """
  Cast attributes into a changeset
  """
  defdelegate change_role(role, attrs \\ %{}), to: Roles

  @doc """
  Delete role
  """
  defdelegate delete_role(role), to: Roles

  @doc """
  Activate a role
  """
  defdelegate activate_role(role), to: Roles

  @doc """
  Desactivate a role.

  Will revoke all sessions.

  This will NOT disconnect live views, this is the responsibility of the
  web layer.
  """
  defdelegate deactivate_role(role), to: Roles

  @doc """
  Load session assoc with all permissions
  """
  defdelegate load_sessions(role), to: Roles

  @doc """
  Return all active roles for type
  """
  defdelegate active_roles(type), to: Roles

  alias VacEngine.Account.AccessTokens

  @doc """
  Return all API tokens
  """
  defdelegate list_api_tokens(), to: AccessTokens

  @doc """
  Load te `api_tokens` assoc of a given role
  """
  defdelegate load_api_tokens(role), to: AccessTokens

  @doc """
  Generates a human friendly secret of `length` bytes long.

  Length must be multiple of 4.

  Crypto secure.
  """
  defdelegate generate_secret(length \\ 16), to: AccessTokens

  @doc """
  Create an access token as API for a given role
  """
  defdelegate create_api_token(role), to: AccessTokens

  @doc """
  Generate a secret with a prefix and id.
  """
  defdelegate generate_composite_secret(prefix, id), to: AccessTokens

  @doc """
  Explode a secret.

      iex> sec = generate_composite_secret(:role, 23)
      ...> %{id: 23, prefix: "role", secret: _} = explode_composite_secret(sec)
  """
  defdelegate explode_composite_secret(secret), to: AccessTokens

  alias VacEngine.Pub

  def list_api_keys() do
    # TODO actually check role portal id permissions
    portals =
      Pub.list_portals()
      |> Enum.map(fn portal ->
        portal
        |> Pub.active_publications()
        |> case do
          nil ->
            nil

          publi ->
            {portal.id, %{blueprint_id: publi.blueprint_id}}
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Map.new()

    Roles.active_roles(:api)
    |> Enum.map(fn r ->
      r
      |> AccessTokens.load_api_tokens()
      |> Map.get(:api_tokens)
      |> Enum.map(fn t ->
        %{secret: t.secret, portals: portals}
      end)
    end)
    |> List.flatten()
  end
end
