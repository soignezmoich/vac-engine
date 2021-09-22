defmodule VacEngine.Permissions do
  alias VacEngine.Accounts.Role
  alias VacEngine.Accounts.GlobalPermission
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

  def toggle(role, name, key) do
    change_global(role, name, key, :toggle)
  end

  defp change_global(role, name, key, value) do
    Multi.new()
    |> Multi.run(:perm, fn repo, _changes ->
      {:ok,
       repo.get_by(GlobalPermission, role_id: role.id) ||
         GlobalPermission.new(role)}
    end)
    |> Multi.insert_or_update(:update, fn %{perm: perm} ->
      value =
        if value == :toggle do
          !(Map.get(perm, name) |> Map.get(key))
        else
          value
        end

      values =
        Map.get(perm, name)
        |> Map.put(key, value)

      values =
        cond do
          value == false && key == :read ->
            %{write: false, delegate: false, delete: false, read: false}

          value == true && key != :read ->
            Map.put(values, :read, true)
          true -> values
        end

      GlobalPermission.changeset(perm, %{
        Atom.to_string(name) => values
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
