defmodule VacEngineWeb.LiveRole do
  import Phoenix.LiveView
  alias VacEngine.Account

  def mount(_params, %{"role_session_token" => token} = _session, socket) do
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

    {:cont, socket}
  end

  def mount(_params, _session, socket) do
    {:halt, redirect(socket, to: "/login")}
  end
end
