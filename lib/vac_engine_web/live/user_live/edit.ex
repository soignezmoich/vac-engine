defmodule VacEngineWeb.UserLive.Edit do
  use VacEngineWeb, :live_view
  use VacEngineWeb.TooltipHelpers

  import VacEngineWeb.PermissionHelpers
  alias VacEngine.Account
  alias VacEngineWeb.Router.Helpers, as: Routes

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin user)a})

  @impl true
  def mount(%{"user_id" => uid}, _session, socket) do
    can!(socket, :manage, :users)

    {:ok, user} = Account.fetch_user(uid)

    changeset =
      user
      |> Account.change_user()
      |> Map.put(:action, :update)

    {:ok,
     assign(socket,
       edit: can?(socket, :users, :write) && !self?(socket, user),
       user: user,
       changeset: changeset,
       current_tooltip: nil,
       clear_tooltip_ref: nil,
       generated_password: nil
     )}
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
    not_self!(socket, user)
    can!(socket, :manage, :users)

    Account.update_user(socket.assigns.user, params)
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
        %{"key" => key},
        %{assigns: %{current_tooltip: key, user: user}} = socket
      ) do
    not_self!(socket, user)
    can!(socket, :manage, :users)

    pass = Account.generate_secret(8)

    {:ok, _user} =
      Account.update_user(socket.assigns.user, %{"password" => pass})

    {:noreply,
     socket
     |> clear_tooltip
     |> reload_user
     |> assign(generated_password: pass)}
  end

  @impl true
  def handle_event(
        "generate_password",
        %{"key" => key},
        socket
      ) do
    {:noreply, set_tooltip(socket, key)}
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
        "toggle_permission",
        %{"key" => permission},
        %{assigns: %{current_tooltip: permission, user: user}} = socket
      ) do
    not_self!(socket, user)
    can!(socket, :manage, :users)

    {:ok, _role} = Account.toggle_permission(user.role, permission)

    :ok = VacEngineWeb.Endpoint.disconnect_live_views(user)

    {:noreply,
     socket
     |> clear_tooltip
     |> reload_user}
  end

  @impl true
  def handle_event(
        "toggle_permission",
        %{"key" => permission},
        socket
      ) do
    {:noreply, set_tooltip(socket, permission)}
  end

  @impl true
  def handle_event(
        "revoke_session",
        %{"key" => key},
        %{assigns: %{current_tooltip: key, user: user}} = socket
      ) do
    not_self!(socket, user)
    can!(socket, :manage, :users)

    "revoke_session_" <> session_id = key

    session = Account.get_session!(session_id)
    check!(session.role_id == user.role_id)

    {:ok, session} = Account.revoke_session(session)

    :ok = VacEngineWeb.Endpoint.disconnect_live_views(session)

    {:noreply,
     socket
     |> clear_tooltip
     |> reload_user}
  end

  @impl true
  def handle_event(
        "revoke_session",
        %{"key" => key},
        socket
      ) do
    {:noreply, set_tooltip(socket, key)}
  end

  @impl true
  def handle_event(
        "toggle_active",
        %{"key" => key},
        %{assigns: %{current_tooltip: key, user: user}} = socket
      ) do
    not_self!(socket, user)
    can!(socket, :manage, :users)

    {:ok, role} =
      if user.role.active do
        Account.deactivate_role(user.role)
      else
        Account.activate_role(user.role)
      end

    :ok = VacEngineWeb.Endpoint.disconnect_live_views(role)

    {:noreply,
     socket
     |> clear_tooltip
     |> reload_user}
  end

  @impl true
  def handle_event(
        "toggle_active",
        %{"key" => key},
        socket
      ) do
    {:noreply, set_tooltip(socket, key)}
  end

  def reload_user(%{assigns: %{user: user}} = socket) do
    {:ok, user} = Account.fetch_user(user.id)

    changeset =
      user
      |> Account.change_user()
      |> Map.put(:action, :update)

    assign(socket, user: user, changeset: changeset)
  end
end
