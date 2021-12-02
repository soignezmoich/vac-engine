defmodule VacEngineWeb.ApiKeyLive.Edit do
  use VacEngineWeb, :live_view

  alias VacEngine.Account
  alias VacEngine.Query
  alias VacEngine.Pub
  alias VacEngine.EnumHelpers
  alias VacEngineWeb.PermissionToggleComponent
  alias VacEngineWeb.InlineSearchComponent

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin api_key new)a})

  @impl true
  def mount(
        %{"role_id" => role_id},
        _session,
        socket
      ) do
    can!(socket, :manage, :api_keys)

    {:ok,
     assign(socket,
       role_id: role_id,
       secret_visible: false,
       workspace_results: [],
       portal_results: []
     )
     |> reload_role}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{"role" => params},
        %{assigns: %{edited_role: role}} = socket
      ) do
    changeset =
      role
      |> Account.change_role(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event(
        "update",
        %{"role" => params},
        %{assigns: %{edited_role: role}} = socket
      ) do
    can!(socket, :manage, :api_keys)

    Account.update_role(role, params)
    |> case do
      {:ok, role} ->
        {:noreply,
         socket
         |> push_redirect(to: Routes.api_key_path(socket, :edit, role))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("reveal_secret", _, socket) do
    Process.send_after(self(), :hide_secret, 10_000)

    {:noreply,
     socket
     |> assign(secret_visible: true)}
  end

  @impl true
  def handle_event(
        "delete",
        _,
        %{assigns: %{edited_role: role}} = socket
      ) do
    can!(socket, :manage, :api_keys)
    {:ok, _} = Account.delete_role(role)

    {:noreply,
     socket
     |> push_redirect(to: Routes.api_key_path(socket, :index), replace: true)}
  end

  @impl true
  def handle_event(
        "search_workspaces",
        %{"query" => %{"query" => search}},
        %{assigns: %{edited_role: edited_role}} = socket
      )
      when is_binary(search) and byte_size(search) > 0 do
    can!(socket, :manage, :api_keys)

    results =
      Account.list_workspaces(fn query ->
        query
        |> Query.filter_by_query(search)
        |> Query.limit(10)
      end)

    remove_workspaces =
      edited_role.workspace_permissions
      |> Enum.map(fn p -> {p.workspace_id, true} end)
      |> Map.new()

    results =
      Enum.filter(results, fn w -> not Map.has_key?(remove_workspaces, w.id) end)

    {:noreply, assign(socket, workspace_results: results)}
  end

  @impl true
  def handle_event("search_workspaces", _, socket) do
    {:noreply, assign(socket, workspace_results: [])}
  end

  @impl true
  def handle_event(
        "define_workspace_permission",
        %{"id" => wid},
        %{assigns: %{edited_role: edited_role, workspace_results: results}} =
          socket
      ) do
    can!(socket, :manage, :api_keys)

    {wid, _} = Integer.parse(wid)

    send_update(InlineSearchComponent,
      id: "search_workspaces",
      search_visible: false
    )

    workspace = EnumHelpers.find_by(results, :id, wid)

    {:ok, _perm} = Account.create_permissions(edited_role, workspace)

    {:noreply, assign(socket, workspace_results: []) |> reload_role}
  end

  @impl true
  def handle_event(
        "delete_workspace_permission",
        %{"id" => pid},
        %{assigns: %{edited_role: edited_role}} = socket
      ) do
    can!(socket, :manage, :api_keys)

    {pid, _} = Integer.parse(pid)

    perm = EnumHelpers.find_by(edited_role.workspace_permissions, :id, pid)

    {:ok, _perm} = Account.delete_permissions(edited_role, perm.workspace)

    {:noreply, reload_role(socket)}
  end

  @impl true
  def handle_event(
        "search_portals",
        %{"query" => %{"query" => search}},
        %{assigns: %{edited_role: edited_role}} = socket
      )
      when is_binary(search) and byte_size(search) > 0 do
    can!(socket, :manage, :api_keys)

    results =
      Pub.list_portals(fn query ->
        query
        |> Query.filter_by_query(search)
        |> Query.limit(10)
      end)

    remove_portals =
      edited_role.portal_permissions
      |> Enum.map(fn b -> {b.portal_id, true} end)
      |> Map.new()

    results =
      Enum.filter(results, fn w -> not Map.has_key?(remove_portals, w.id) end)

    {:noreply, assign(socket, portal_results: results)}
  end

  @impl true
  def handle_event("search_portals", _, socket) do
    {:noreply, assign(socket, portal_results: [])}
  end

  @impl true
  def handle_event(
        "define_portal_permission",
        %{"id" => id},
        %{assigns: %{edited_role: edited_role, portal_results: results}} =
          socket
      ) do
    can!(socket, :manage, :api_keys)

    {id, _} = Integer.parse(id)

    send_update(InlineSearchComponent,
      id: "search_portals",
      search_visible: false
    )

    portal = EnumHelpers.find_by(results, :id, id)

    {:ok, _perm} = Account.create_permissions(edited_role, portal)

    {:noreply, assign(socket, portal_results: []) |> reload_role}
  end

  @impl true
  def handle_event(
        "delete_portal_permission",
        %{"id" => pid},
        %{assigns: %{edited_role: edited_role}} = socket
      ) do
    can!(socket, :manage, :api_keys)

    {pid, _} = Integer.parse(pid)

    perm = EnumHelpers.find_by(edited_role.portal_permissions, :id, pid)

    {:ok, _perm} = Account.delete_permissions(edited_role, perm.portal)

    {:noreply, reload_role(socket)}
  end

  @impl true
  def handle_info(:hide_secret, socket) do
    {:noreply, assign(socket, secret_visible: false)}
  end

  @impl true
  def handle_info({:toggle_permission, role, action, scope}, socket) do
    can!(socket, :manage, :api_keys)

    {:ok, _perm} = Account.toggle_permission(role, action, scope)

    {:noreply,
     socket
     |> reload_role}
  end

  defp reload_role(socket) do
    role =
      Account.get_role!(socket.assigns.role_id, fn q ->
        q
        |> Account.load_api_tokens()
        |> Account.load_role_permission_scopes()
      end)

    changeset =
      role
      |> Account.change_role()
      |> Map.put(:action, :update)

    assign(socket,
      edited_role: role,
      changeset: changeset,
      token: List.first(role.api_tokens)
    )
  end
end
