defmodule VacEngine.Account.Permissions do
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Account.GlobalPermission
  alias VacEngine.Account.Role

  def global_permissions_multi(role) do
    Multi.new()
    |> Multi.insert(:global_permissions, fn _ ->
      GlobalPermission.new(role)
    end)
  end

  def has_permission?(%Role{} = role, path) do
    check_permission(role, path)
  end

  def grant_permission(%Role{} = role, path) do
    change_permission(role, path, true)
  end

  def revoke_permission(%Role{} = role, path) do
    change_permission(role, path, false)
  end

  def toggle_permission(%Role{} = role, path) do
    change_permission(role, path, :toggle)
  end

  defp change_permission(role, path, value) when is_binary(path) do
    String.split(path, ".")
    |> case do
      ["global", name, key] ->
        change_permission(
          role,
          [
            :global,
            String.to_existing_atom(name),
            String.to_existing_atom(key)
          ],
          value
        )

      _ ->
        {:error, "not implemented"}
    end
  end

  defp change_permission(role, [:global, name, key], value) do
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

          true ->
            values
        end

      GlobalPermission.changeset(perm, %{
        Atom.to_string(name) => values
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} -> {:ok, role}
      err -> err
    end
  end

  defp check_permission(role, path) when is_binary(path) do
    String.split(path, ".")
    |> case do
      ["global", name, key] ->
        check_permission(
          role,
          [
            :global,
            String.to_existing_atom(name),
            String.to_existing_atom(key)
          ]
        )

      _ ->
        false
    end
  end

  defp check_permission(role, [:global, name, key]) do
    role.global_permission
    |> Map.get(name)
    |> Map.get(key)
  end
end
