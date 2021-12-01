defmodule VacEngine.Account.Can do
  @moduledoc false

  alias VacEngine.Account.Role
  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Pub.Portal
  alias VacEngine.EnumHelpers

  @doc """
  Can check if the role can do the action via a direct or indirect permission
  """
  def can?(role, action, scope \\ :global)

  def can?(%Role{global_permission: %{super_admin: true}}, _, _), do: true

  def can?(role, action, %Workspace{id: wid}) do
    wp_can?(role, action, wid)
  end

  def can?(role, action, %Blueprint{id: bid, workspace_id: wid}) do
    w_action =
      case action do
        :read -> :read_blueprints
        :write -> :write_blueprints
      end

    wp_can?(role, w_action, wid) || br_can?(role, action, bid)
  end

  def can?(role, action, %Portal{id: pid, workspace_id: wid}) do
    w_action =
      case action do
        :read -> :read_portals
        :write -> :write_portals
        :run -> :run_portals
      end

    wp_can?(role, w_action, wid) || po_can?(role, action, pid)
  end

  def can?(_, _, _), do: false

  defp wp_can?(%Role{workspace_permissions: workspace_perms}, action, id) do
    p = EnumHelpers.find_by(workspace_perms, :workspace_id, id)
    p != nil && Map.get(p, action)
  end

  defp br_can?(%Role{blueprint_permissions: blueprint_perms}, action, id) do
    p = EnumHelpers.find_by(blueprint_perms, :blueprint_id, id)
    p != nil && Map.get(p, action)
  end

  defp po_can?(%Role{portal_permissions: portal_perms}, action, id) do
    p = EnumHelpers.find_by(portal_perms, :portal_id, id)
    p != nil && Map.get(p, action)
  end

  @doc """
  Has check directly for permission existence
  """
  def has?(role, action, scope \\ :global)

  def has?(
        %Role{global_permission: %{super_admin: res}},
        :super_admin,
        :global
      ),
      do: res

  def has?(
        %Role{workspace_permissions: perms},
        action,
        %Workspace{id: id}
      ) do
    perm = EnumHelpers.find_by(perms, :workspace_id, id)
    perm != nil && Map.get(perm, action)
  end

  def has?(
        %Role{blueprint_permissions: perms},
        action,
        %Blueprint{id: id}
      ) do
    perm = EnumHelpers.find_by(perms, :blueprint_id, id)
    perm != nil && Map.get(perm, action)
  end

  def has?(
        %Role{portal_permissions: perms},
        action,
        %Portal{id: id}
      ) do
    perm = EnumHelpers.find_by(perms, :portal_id, id)
    perm != nil && Map.get(perm, action)
  end
end
