defmodule VacEngineWeb.LiveRole do
  import Phoenix.LiveView
  alias VacEngine.Account

  def on_mount(
        :default,
        _params,
        %{"role_session_token" => token} = _session,
        socket
      ) do
    socket =
      socket
      |> assign_new(:role_session, fn ->
        {:ok, session} = Account.fetch_session(token)
        session
      end)

    socket =
      socket
      |> assign_new(:role, fn ->
        socket.assigns.role_session.role
      end)

    socket =
      socket
      |> assign_new(:workspaces, fn ->
        role = socket.assigns.role_session.role

        Account.list_workspaces(fn query ->
          query
          |> Account.filter_accessible_workspaces(role)
          |> Account.order_workspaces_by(:name)
        end)
      end)

    {:cont, socket}
  end

  def on_mount(:default, _params, _session, socket) do
    {:halt, redirect(socket, to: "/login")}
  end
end
