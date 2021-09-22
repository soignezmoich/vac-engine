defmodule VacEngineWeb.LivePermissions do
  import Phoenix.LiveView
  alias VacEngine.Accounts

  def mount(params, %{"role_session_token" => token} = _session, socket) do
    socket =
      assign_new(socket, :role_session, fn ->
        {:ok, session} = Accounts.fetch_session(token)
        session
      end)

    {:cont, socket}
  end

  def mount(params, _session, socket) do
    {:halt, redirect(socket, to: "/login")}
  end
end
