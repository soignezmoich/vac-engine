defmodule VacEngineWeb.LivePermissions do
  import Phoenix.LiveView
  alias VacEngine.Auth

  def mount(params, %{"role_session_token" => token} = _session, socket) do
    socket =
      assign_new(socket, :role_session, fn ->
        {:ok, session} = Auth.fetch_session(token)
        session
      end)

    {:cont, socket}
  end

  def mount(params, _session, socket) do
    {:halt, redirect(socket, to: "/login")}
  end

  def can?(socket, name, key) do
    VacEngine.Permissions.can?(socket.assigns.role_session.role, name, key)
  end
end

defmodule VacEngineWeb.RoleLiveError do
  defexception message: "unauthorized", plug_status: 403
end
