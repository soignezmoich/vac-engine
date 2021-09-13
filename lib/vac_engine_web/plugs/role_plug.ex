defmodule VacEngineWeb.RolePlug do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]
  import VacEngineWeb.ConnUtils

  alias VacEngine.Auth

  def fetch_role_session(conn, _) do
    with {:ok, session} <- restore_session(conn) do
      conn
      |> assign(:role_session, session)
      |> assign(:role, session.role)
    else
      _ ->
        conn
        |> assign(:role_session, nil)
        |> assign(:role, nil)
    end
  end

  def require_role(conn, _) do
    if conn.assigns[:role] == nil do
      conn
      |> put_session("login_next_url", conn.request_path)
      |> redirect(to: "/login")
      |> halt
    else
      conn
    end
  end

  def require_no_role(conn, _) do
    if conn.assigns[:role] != nil do
      conn
      |> redirect(to: "/")
      |> halt
    else
      conn
    end
  end

  defp restore_session(conn) do
    with {:ok, session} <-
           conn |> get_session("role_session_token") |> Auth.fetch_session(),
         {:ok, session} <-
           Auth.update_session(session, session_attrs(conn)) do
      {:ok, session}
    else
      _ -> {:error, "cannot fetch an update session"}
    end
  end
end
