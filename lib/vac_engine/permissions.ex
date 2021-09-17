defmodule VacEngine.Permissions do
  alias VacEngine.Auth.Role
  alias VacEngine.Auth.GlobalPermission
  alias Ecto.Multi
  alias VacEngine.Repo

  def can?(role, name, key) do
    check_global(role, name, key)
  end

  def grant(role, name, key) do
    change_global(role, name, key, true)
  end

  def revoke(role, name, key) do
    change_global(role, name, key, false)
  end

  defp change_global(role, name, key, value) do
    Multi.new()
    |> Multi.run(:perm, fn repo, _changes ->
      {:ok,
       repo.get_by(GlobalPermission, role_id: role.id) ||
         GlobalPermission.new(role)}
    end)
    |> Multi.insert_or_update(:update, fn %{perm: perm} ->
      GlobalPermission.changeset(perm, %{
        Atom.to_string(name) => Map.put(Map.get(perm, name), key, value)
      })
    end)
    |> Repo.transaction()
  end

  defp check_global(%{global_permission: nil} = role, _name, _key), do: false

  defp check_global(role, name, key) do
    role.global_permission
    |> Map.get(name)
    |> Map.get(key)
  end
end
