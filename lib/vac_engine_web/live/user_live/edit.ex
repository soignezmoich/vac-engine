defmodule VacEngineWeb.UserLive.Edit do
  use VacEngineWeb, :live_view

  alias VacEngineWeb.PermissionToggleComponent
  alias VacEngineWeb.InlineSearchComponent
  import VacEngineWeb.PermissionHelpers
  alias VacEngine.Account
  alias VacEngine.Query
  alias VacEngine.Processor
  alias VacEngineWeb.Router.Helpers, as: Routes
  alias VacEngine.EnumHelpers

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin user)a})

  @impl true
  def mount(%{"user_id" => uid}, _session, socket) do
    can!(socket, :manage, :users)

    {:ok,
     assign(socket,
       edit: true,
       user_id: uid,
       generated_password: nil,
       workspace_results: [],
       blueprint_results: []
     )
     |> reload_user}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{"user" => params},
        socket
      ) do
    changeset =
      socket.assigns.user
      |> Account.change_user(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event(
        "update",
        %{"user" => params},
        %{assigns: %{user: user}} = socket
      ) do
    can!(socket, :manage, :users)

    Account.update_user(user, params)
    |> case do
      {:ok, user} ->
        {:noreply,
         socket
         |> push_redirect(to: Routes.user_path(socket, :edit, user))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event(
        "generate_password",
        _,
        %{assigns: %{user: user}} = socket
      ) do
    not_myself!(socket, user)
    can!(socket, :manage, :users)

    pass = Account.generate_secret(8)

    {:ok, _user} =
      Account.update_user(socket.assigns.user, %{"password" => pass})

    {:noreply,
     socket
     |> reload_user
     |> assign(generated_password: pass)}
  end

  @impl true
  def handle_event(
        "reset_totp",
        _,
        %{assigns: %{user: user}} = socket
      ) do
    not_myself!(socket, user)
    can!(socket, :manage, :users)

    {:ok, _user} = Account.update_user(user, %{totp_secret: nil})

    {:noreply, socket |> reload_user}
  end

  @impl true
  def handle_event(
        "hide_generated_password",
        _,
        socket
      ) do
    {:noreply, assign(socket, generated_password: nil)}
  end

  @impl true
  def handle_event(
        "revoke_session",
        %{"id" => session_id},
        %{assigns: %{user: user}} = socket
      ) do
    not_myself!(socket, user)
    can!(socket, :manage, :users)

    session = Account.get_session!(session_id)
    check!(session.role_id == user.role_id)

    {:ok, session} = Account.revoke_session(session)

    :ok = VacEngineWeb.Endpoint.disconnect_live_views(session)

    {:noreply,
     socket
     |> reload_user}
  end

  @impl true
  def handle_event(
        "toggle_active",
        _,
        %{assigns: %{user_role: role}} = socket
      ) do
    not_myself!(socket, role)
    can!(socket, :manage, :users)

    {:ok, role} =
      if role.active do
        Account.deactivate_role(role)
      else
        Account.activate_role(role)
      end

    :ok = VacEngineWeb.Endpoint.disconnect_live_views(role)

    {:noreply,
     socket
     |> reload_user}
  end

  @impl true
  def handle_event(
        "search_workspaces",
        %{"query" => %{"query" => search}},
        %{assigns: %{user_role: user_role}} = socket
      )
      when is_binary(search) and byte_size(search) > 0 do
    can!(socket, :manage, :users)

    results =
      Account.list_workspaces(fn query ->
        query
        |> Query.filter_by_query(search)
        |> Query.limit(10)
      end)

    remove_workspaces =
      user_role.workspace_permissions
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
        %{assigns: %{user_role: user_role, workspace_results: results}} = socket
      ) do
    can!(socket, :manage, :users)

    {wid, _} = Integer.parse(wid)

    send_update(InlineSearchComponent,
      id: "search_workspaces",
      search_visible: false
    )

    workspace = EnumHelpers.find_by(results, :id, wid)

    {:ok, _perm} = Account.create_permissions(user_role, workspace)

    :ok = VacEngineWeb.Endpoint.disconnect_live_views(user_role)

    {:noreply, assign(socket, workspace_results: []) |> reload_user}
  end

  @impl true
  def handle_event(
        "delete_workspace_permission",
        %{"id" => pid},
        %{assigns: %{user_role: user_role}} = socket
      ) do
    can!(socket, :manage, :users)

    {pid, _} = Integer.parse(pid)

    perm = EnumHelpers.find_by(user_role.workspace_permissions, :id, pid)

    {:ok, _perm} = Account.delete_permissions(user_role, perm.workspace)

    :ok = VacEngineWeb.Endpoint.disconnect_live_views(user_role)

    {:noreply, reload_user(socket)}
  end

  @impl true
  def handle_event(
        "search_blueprints",
        %{"query" => %{"query" => search}},
        %{assigns: %{user_role: user_role}} = socket
      )
      when is_binary(search) and byte_size(search) > 0 do
    can!(socket, :manage, :users)

    results =
      Processor.list_blueprints(fn query ->
        query
        |> Query.filter_by_query(search)
        |> Query.limit(10)
      end)

    remove_blueprints =
      user_role.blueprint_permissions
      |> Enum.map(fn b -> {b.blueprint_id, true} end)
      |> Map.new()

    results =
      Enum.filter(results, fn w -> not Map.has_key?(remove_blueprints, w.id) end)

    {:noreply, assign(socket, blueprint_results: results)}
  end

  @impl true
  def handle_event("search_blueprints", _, socket) do
    {:noreply, assign(socket, blueprint_results: [])}
  end

  @impl true
  def handle_event(
        "define_blueprint_permission",
        %{"id" => wid},
        %{assigns: %{user_role: user_role, blueprint_results: results}} = socket
      ) do
    can!(socket, :manage, :users)

    {wid, _} = Integer.parse(wid)

    send_update(InlineSearchComponent,
      id: "search_blueprints",
      search_visible: false
    )

    blueprint = EnumHelpers.find_by(results, :id, wid)

    {:ok, _perm} = Account.create_permissions(user_role, blueprint)

    :ok = VacEngineWeb.Endpoint.disconnect_live_views(user_role)

    {:noreply, assign(socket, blueprint_results: []) |> reload_user}
  end

  @impl true
  def handle_event(
        "delete_blueprint_permission",
        %{"id" => pid},
        %{assigns: %{user_role: user_role}} = socket
      ) do
    can!(socket, :manage, :users)

    {pid, _} = Integer.parse(pid)

    perm = EnumHelpers.find_by(user_role.blueprint_permissions, :id, pid)

    {:ok, _perm} = Account.delete_permissions(user_role, perm.blueprint)

    :ok = VacEngineWeb.Endpoint.disconnect_live_views(user_role)

    {:noreply, reload_user(socket)}
  end

  @impl true
  def handle_info({:toggle_permission, role, action, scope}, socket) do
    not_myself!(socket, role)
    can!(socket, :manage, :users)

    {:ok, _perm} = Account.toggle_permission(role, action, scope)

    :ok = VacEngineWeb.Endpoint.disconnect_live_views(role)

    {:noreply,
     socket
     |> reload_user}
  end

  defp reload_user(%{assigns: %{user_id: uid}} = socket) do
    user = Account.get_user!(uid)

    role =
      Account.get_role!(user.role_id, fn q ->
        q
        |> Account.load_role_sessions()
        |> Account.load_role_permission_scopes()
      end)

    changeset =
      user
      |> Account.change_user()
      |> Map.put(:action, :update)

    assign(socket,
      user: user,
      changeset: changeset,
      user_role: role,
      edit_perm: not myself?(socket, role)
    )
  end
end
