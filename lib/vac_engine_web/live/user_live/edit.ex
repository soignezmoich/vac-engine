defmodule VacEngineWeb.UserLive.Edit do
  use VacEngineWeb, :live_view

  import VacEngineWeb.PermissionHelpers
  alias VacEngine.Account
  alias VacEngineWeb.Router.Helpers, as: Routes

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin user)a})

  @impl true
  def mount(%{"user_id" => uid}, _session, socket) do
    can!(socket, :manage, :users)

    {:ok,
     assign(socket,
       edit: can?(socket, :users, :write),
       user_id: uid,
       generated_password: nil
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
        "toggle_permission",
        _,
        %{assigns: %{user_role: role}} = socket
      ) do
    not_myself!(socket, role)
    can!(socket, :manage, :users)

    {:ok, _perm} = Account.toggle_permission(role, :super_admin)

    :ok = VacEngineWeb.Endpoint.disconnect_live_views(role)

    {:noreply,
     socket
     |> reload_user}
  end

  @impl true
  def handle_event(
        "revoke_session",
        %{"id" => session_id},
        %{assigns: %{user: user}} = socket
      ) do
    not_myself!(socket, user)

    session = Account.get_session!(session_id)

    can!(socket, :revoke, session)
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

  def reload_user(%{assigns: %{user_id: uid}} = socket) do
    user = Account.get_user!(uid)

    role = Account.get_role!(user.role_id, &Account.load_role_sessions/1)

    changeset =
      user
      |> Account.change_user()
      |> Map.put(:action, :update)

    assign(socket,
      user: user,
      changeset: changeset,
      user_role: role,
      myself: myself?(socket, user)
    )
  end
end
