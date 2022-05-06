defmodule VacEngineWeb.RolePlug do
  @moduledoc false

  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]
  import VacEngineWeb.ConnHelpers

  alias VacEngine.Account

  def fetch_role_session(conn, _) do
    conn
    |> restore_session
    |> case do
      {:ok, session} ->
        conn
        |> assign(:role_session, session)
        |> assign(:role, session.role)

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
           conn |> get_session("role_session_token") |> Account.fetch_session(),
         {:ok, session} <-
           Account.update_session(session, session_attrs(conn)) do
      {:ok, session}
    else
      _ -> {:error, "cannot restore session"}
    end
  end
end
