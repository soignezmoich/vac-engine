defmodule VacEngine.Account.Permissions do
  @moduledoc false

  alias Ecto.Multi
  import Ecto.Query
  alias VacEngine.Repo
  alias VacEngine.Account.GlobalPermission
  alias VacEngine.Account.WorkspacePermission
  alias VacEngine.Account.Workspace
  alias VacEngine.Account.PortalPermission
  alias VacEngine.Account.BlueprintPermission
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Pub.Portal
  import VacEngine.EctoHelpers, only: [transaction: 2, delete_all: 1]

  def grant_permission(role, action, scope) do
    do_change_permission(role, scope, %{action => true})
  end

  def revoke_permission(role, action, scope) do
    do_change_permission(role, scope, %{action => false})
  end

  def toggle_permission(role, action, scope) do
    do_change_permission(role, scope, %{action => :toggle})
  end

  def has_permission?(role, action, scope) do
    get_permissions(role, scope)
    |> case do
      nil -> false
      perm -> Map.get(perm, action)
    end
  end

  def delete_permissions(_role, :global) do
    raise "global scope permission cannot be deleted"
  end

  def delete_permissions(role, scope) do
    do_delete_permissions(role, scope)
  end

  def create_permissions(role, scope) do
    do_change_permission(role, scope, %{})
  end

  defp do_change_permission(_role, nil, _) do
    {:error, "permission scope not found"}
  end

  defp do_change_permission(role, :global, attrs) do
    Multi.new()
    |> Multi.run(:perm, fn repo, _changes ->
      {:ok, repo.get_by!(GlobalPermission, role_id: role.id)}
    end)
    |> Multi.update(:update, fn %{perm: perm} ->
      GlobalPermission.changeset(perm, bake_toggle(perm, attrs))
    end)
    |> transaction(:update)
  end

  defp do_change_permission(role, %Workspace{id: wid}, attrs) do
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

  defp do_change_permission(role, %Blueprint{id: bid}, attrs) do
    Multi.new()
    |> Multi.run(:ids, fn repo, _changes ->
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
          blueprint_id: blueprint_id
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

  defp do_change_permission(role, %Portal{id: pid}, attrs) do
    Multi.new()
    |> Multi.run(:ids, fn repo, _changes ->
      from(r in Portal, where: r.id == ^pid, select: {r.id, r.workspace_id})
      |> repo.one
      |> case do
        nil -> {:error, "portal not found"}
        ids -> {:ok, ids}
      end
    end)
    |> Multi.run(:perm, fn repo, %{ids: {portal_id, workspace_id}} ->
      perm =
        repo.get_by(PortalPermission,
          role_id: role.id,
          portal_id: portal_id
        ) ||
          %PortalPermission{
            role_id: role.id,
            portal_id: portal_id,
            workspace_id: workspace_id
          }

      {:ok, perm}
    end)
    |> Multi.insert_or_update(:update, fn %{perm: perm} ->
      PortalPermission.changeset(perm, bake_toggle(perm, attrs))
    end)
    |> transaction(:update)
  end

  defp do_delete_permissions(role, %Workspace{id: wid}) do
    from(p in WorkspacePermission,
      where: p.workspace_id == ^wid and p.role_id == ^role.id
    )
    |> delete_all()
  end

  defp do_delete_permissions(role, %Blueprint{id: bid}) do
    from(p in BlueprintPermission,
      where: p.blueprint_id == ^bid and p.role_id == ^role.id
    )
    |> delete_all()
  end

  defp do_delete_permissions(role, %Portal{id: pid}) do
    from(p in PortalPermission,
      where: p.portal_id == ^pid and p.role_id == ^role.id
    )
    |> delete_all()
  end

  def get_permissions(role, :global) do
    from(p in GlobalPermission,
      where: p.role_id == ^role.id
    )
    |> Repo.one()
  end

  def get_permissions(role, %Workspace{id: wid}) do
    from(p in WorkspacePermission,
      where: p.workspace_id == ^wid and p.role_id == ^role.id
    )
    |> Repo.one()
  end

  def get_permissions(role, %Blueprint{id: bid}) do
    from(p in BlueprintPermission,
      where: p.blueprint_id == ^bid and p.role_id == ^role.id
    )
    |> Repo.one()
  end

  def get_permissions(role, %Portal{id: pid}) do
    from(p in PortalPermission,
      where: p.portal_id == ^pid and p.role_id == ^role.id
    )
    |> Repo.one()
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
