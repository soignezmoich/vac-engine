defmodule VacEngine.Account.Can do
  @moduledoc false

  alias VacEngine.Account.Role

  def can?(role, action, scope \\ :global)

  def can?(%Role{global_permission: %{super_admin: true}}, _, _), do: true

  def can?(%Role{workspace_permissions: _perms}, _action, {:workspace, _wid}) do
    false
  end

  def can?(_, _, _), do: false
end
