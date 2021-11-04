defmodule VacEngine.Account.Permissions do
  @moduledoc false

  alias Ecto.Multi
  import Ecto.Query
  alias VacEngine.Account.GlobalPermission
  alias VacEngine.Account.WorkspacePermission
  alias VacEngine.Account.Workspace
  alias VacEngine.Account.BlueprintPermission
  alias VacEngine.Processor.Blueprint
  import VacEngine.EctoHelpers, only: [transaction: 2]

  def grant_permission(role, action, scope) do
    change_permission(role, scope, %{action => true})
  end

  def revoke_permission(role, action, scope) do
    change_permission(role, scope, %{action => false})
  end

  def toggle_permission(role, action, scope) do
    change_permission(role, scope, %{action => :toggle})
  end

  defp change_permission(_role, nil, _) do
    {:error, "permission scope not found"}
  end

  defp change_permission(role, :global, attrs) do
    Multi.new()
    |> Multi.run(:perm, fn repo, _changes ->
      {:ok, repo.get_by!(GlobalPermission, role_id: role.id)}
    end)
    |> Multi.update(:update, fn %{perm: perm} ->
      GlobalPermission.changeset(perm, bake_toggle(perm, attrs))
    end)
    |> transaction(:update)
  end

  defp change_permission(role, {:workspace, wid}, attrs) do
    Multi.new()
    |> Multi.run(:workspace_id, fn repo, _changes ->
      from(r in Workspace, where: r.id == ^wid, select: r.id)
      |> repo.one
      |> case do
        nil -> {:error, "workspace not found"}
        wid -> {:ok, wid}
      end
    end)
    |> Multi.run(:perm, fn repo, %{workspace_id: workspace_id} ->
      perm =
        repo.get_by(WorkspacePermission,
          role_id: role.id,
          workspace_id: workspace_id
        ) ||
          %WorkspacePermission{role_id: role.id, workspace_id: workspace_id}

      {:ok, perm}
    end)
    |> Multi.insert_or_update(:update, fn %{perm: perm} ->
      WorkspacePermission.changeset(perm, bake_toggle(perm, attrs))
    end)
    |> transaction(:update)
  end

  defp change_permission(role, {:blueprint, bid}, attrs) do
    Multi.new()
    |> Multi.run(:workspace_id, fn repo, _changes ->
      from(r in Blueprint, where: r.id == ^bid, select: {r.id, r.workspace_id})
      |> repo.one
      |> case do
        nil -> {:error, "blueprint not found"}
        ids -> {:ok, ids}
      end
    end)
    |> Multi.run(:perm, fn repo, %{ids: {blueprint_id, workspace_id}} ->
      perm =
        repo.get_by(BlueprintPermission,
          role_id: role.id,
          blueprint_id: workspace_id
        ) ||
          %BlueprintPermission{
            role_id: role.id,
            blueprint_id: blueprint_id,
            workspace_id: workspace_id
          }

      {:ok, perm}
    end)
    |> Multi.insert_or_update(:update, fn %{perm: perm} ->
      BlueprintPermission.changeset(perm, bake_toggle(perm, attrs))
    end)
    |> transaction(:update)
  end

  defp bake_toggle(perm, attrs) do
    attrs
    |> Enum.map(fn
      {action, :toggle} when is_binary(action) ->
        {action, !Map.get(perm, String.to_existing_atom(action))}

      {action, :toggle} when is_atom(action) ->
        {action, !Map.get(perm, action)}

      e ->
        e
    end)
    |> Map.new()
  rescue
    _ ->
      attrs
  end
end
