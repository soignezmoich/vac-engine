defmodule VacEngine.Account do
  @moduledoc """
  Rsponsible for the management of a role-based permission system.


  ## Roles

  Primary entities to which permissions can be attached.
  Identification to a specific role can be done by using either
  a full authentication or through a token passed with the request.

  Roles can be acquired by two access types: **users** and **api-keys**.

  ### Users

  User access allow people to access the web interface of the application.

  A user can access the application by using a multi-factor authentication
  with:
  - an email login
  - a password
  - a one-time password provided by an authenticator

  User is attached to a single role, to which a set of permissions is granted.

  ### Api-keys

  Api-keys accesses are used by api consumers to call the application api.

  A api-key can access the application by using a token that contain a password
  and a reference to the role. If an existing token is provided with an api
  request in the authentication header, the request is automatically associated
  with the related role and permissions are granted accordingly.

  Curl example of api call with key:

      curl https://example.com/api/p/8/run -X POST \
        -H "Authorization: Bearer api_1234567_123456789012345678901234567890"


  ## Permissions

  ### Granting permission

  Permissions are rights to do certain actions in the system. A permission is
  granted to a role to perform a given in a given scope, by using the
  `grant_permission/3` (or `toggle_permission/3`) function:

      VacEngine.Account.grant_permission(target_role, :list_blueprints_action, :global)

  ### Checking permission

  When a piece of code should only be accessed by roles with defined permission,
  an conditional block containing the `can?/3` function should be added.

      if can?(role, :access, :editor) do
        ...
      end

  The function will return true if and only if the current role has the
  corresponding permission therefore granting access or not to the included
  code.


  ## Actions

  Actions are atoms describing a specific action. The exact content
  of the action is defined by the places where `can?/3` functions use it
  as an argument.


  ## Scopes

  A scope determines a context in which a permission is granted. There is
  three types of scope in the application, the **global** scope,
  the **worspace** scopes and the **custom**.

  #### Global scope

  The global scope correspond to the whole application. Therefore permissions
  granted in the global scope are technically "unscoped".

  Global scope is designated by the `:global` atom.

  #### Workspace scope

  A workspace scope is determined by the id of a workspace and grants the rights
  in the context of this workspace. For example, an `:access` action permission
  in the workspace with `:id = 1` will grant access only to this workspace.

  Workspace scopes are designated a tuple containing the `:workspace` atom and
  the id of the workspace, e.g.:

      {:workspace, 2}


  #### Custom scope

  Other scopes can be created using a custom atom.

  ## Schemas

  Below, the list of the schemas described in the Account module.

  #### AccessToken
  Access tokens can be:
   - API key
   - link token (not implemented yet)
   - oauth refresh token (not implemented yet)
   - oauth access token (not implemented yet)

  Secret format vary depending of the type

  #### BlueprintPermission
  A blueprint permission gives a permission on a blueprint to a role.

  #### GlobalPermission
  A global permission gives a site wide permission to a role.

  #### WorkspacePermission
  A workspace permissions give a workspace wide permission to a role.

  #### Role
  A role is the representation of an actor (user, api request...) to which
  permissions can be attached.

  #### Session
  A session is created every time a user log in and bears the user's
  permissions.

  If the permissions change, the session must be recreated for the change
  to take effect.

  #### User
  A user is a login method for a role of type "user".

  #### Workspace
  The general container for blueprints and portals.

  ## Security design

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

  @doc """
  Check permission directly without infer
  """
  defdelegate has_permission?(role, action, scope \\ :global),
    to: Permissions

  @doc """
  Create permissions for scope
  """
  defdelegate create_permissions(role, scope), to: Permissions

  @doc """
  Delete all permissions for scope
  """
  defdelegate delete_permissions(role, scope), to: Permissions

  alias VacEngine.Account.Can

  @doc """
  Check action against role with scope.
  """
  defdelegate can?(role, action, scope \\ :global), to: Can

  @doc """
  Check action against role with scope.
  """
  defdelegate has?(role, action, scope \\ :global), to: Can

  alias VacEngine.Account.Workspaces

  @doc """
  List all workspaces
  """
  defdelegate list_workspaces(queries \\ & &1), to: Workspaces

  @doc """
  Get a workspace with id, raise if not found.
  """
  defdelegate get_workspace!(id, queries \\ & &1), to: Workspaces

  @doc """
  Filter available workspaces for a given role
  """
  defdelegate filter_accessible_workspaces(query, role), to: Workspaces

  @doc """
  Load blueprints assoc
  """
  defdelegate load_workspace_blueprints(query), to: Workspaces

  @doc """
  Load blueprint_count and active_publication_count
  """
  defdelegate load_workspace_stats(query), to: Workspaces

  @doc """
  Create a workspace with attributes
  """
  defdelegate create_workspace(attrs), to: Workspaces

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

  alias VacEngine.Account.Users

  @doc """
  Return all users with `last_login_at` and `last_active_at` virtual fields
  populated
  """
  defdelegate list_users(queries \\ & &1), to: Users

  @doc """
  Get a user with id, raise if not found.
  """
  defdelegate get_user!(uid, queries \\ & &1), to: Users

  @doc """
  Preload user activity

  Will load role, all sessions and populate `is_active`, `last_login_at` and
  `last_active_at` virtual fields.
  """
  defdelegate load_user_activity(query), to: Users

  @doc """
  Load role assoc
  """
  defdelegate load_user_role(query), to: Users

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
  Update user with attributes. This will cast all user attributes and should
  only be called from an admin context.
  """
  defdelegate update_user(data, attrs), to: Users

  @doc """
  Generate a new TOTP url for the given user.
  Return a `{url, secret}` tuple.
  """
  defdelegate gen_totp(user), to: Users

  alias VacEngine.Account.Sessions

  @doc """
  Try to find a session with given token
  """
  defdelegate fetch_session(token), to: Sessions

  @doc """
  Set session last activity time to now
  """
  defdelegate touch_session(session), to: Sessions

  @doc """
  List sessions
  """
  defdelegate list_sessions(queries \\ & &1), to: Sessions

  @doc """
  Get a session with id, raise if not found.
  """
  defdelegate get_session!(id), to: Sessions

  @doc """
  Filter inactive since n seconds
  """
  defdelegate filter_inactive_sessions(query, duration_sec), to: Sessions

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
  List roles
  """
  defdelegate list_roles(queries \\ & &1), to: Roles

  @doc """
  Get a role with id, raise if not found.
  """
  defdelegate get_role!(id, queries \\ & &1), to: Roles

  @doc """
  Filter role by type
  """
  defdelegate filter_roles_by_type(query, type), to: Roles

  @doc """
  Filter active role
  """
  defdelegate filter_active_roles(query), to: Roles

  @doc """
  Load session assoc
  """
  defdelegate load_role_sessions(query), to: Roles

  @doc """
  Load all permission assoc
  """
  defdelegate load_role_permissions(query), to: Roles

  @doc """
  Load all permission assoc with scope (workspace, portal, blueprint)
  """
  defdelegate load_role_permission_scopes(query), to: Roles

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
  Bust role cache
  """
  defdelegate bust_role_cache(role), to: Roles

  @doc """
  Desactivate a role.

  Will revoke all sessions.

  This will NOT disconnect live views, this is the responsibility of the
  web layer.
  """
  defdelegate deactivate_role(role), to: Roles

  alias VacEngine.Account.AccessTokens

  @doc """
  Return all API tokens
  """
  defdelegate list_api_tokens(queries \\ & &1), to: AccessTokens

  @doc """
  Load te `api_tokens` assoc of a given role
  """
  defdelegate load_api_tokens(query), to: AccessTokens

  @doc """
  Generates a human friendly secret of `length` bytes long.

  Length must be multiple of 4.

  Crypto secure.
  """
  defdelegate generate_secret(length \\ 16), to: AccessTokens

  @doc """
  Create an access token as API for a given role
  """
  defdelegate create_api_token(role, test \\ false), to: AccessTokens

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

  @doc """
  List API keys with portal access for cached API access
  """
  defdelegate list_api_keys(), to: AccessTokens
end
