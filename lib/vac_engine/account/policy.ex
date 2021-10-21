defmodule VacEngine.Account.Policy do
  alias VacEngine.Account.Role
  def can?(role, action), do: can?(role, action, :global)
  def can?(%Role{global_permission: %{super_admin: true}}, _, _), do: true
end
