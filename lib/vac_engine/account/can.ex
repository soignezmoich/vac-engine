defmodule VacEngine.Account.Can do
  alias VacEngine.Account.Role
  def can?(role, action), do: can?(role, action, :global)
  def can?(%Role{global_permission: %{super_admin: true}}, _, _), do: true

  def can?(%Role{workspace_permissions: _perms}, _action, {:workspace, _wid}) do
    false
  end

  def can?(_, _, _), do: false
end
