defmodule VacEngineWeb.AuthController do
  use VacEngineWeb, :controller

  import VacEngineWeb.ConnUtils
  alias VacEngine.Auth

  action_fallback(VacEngineWeb.FallbackController)

  def login(conn, %{"token" => token}) do
    Phoenix.Token.verify(
      VacEngineWeb.Endpoint,
      "login_token",
      token,
      max_age: 10
    )
    |> case do
      {:ok, {user_id, next_url}} ->
        with {:ok, user} <- Auth.fetch_user(user_id),
             {:ok, session} <-
               Auth.create_session(
                 user.role,
                 session_attrs(conn)
               ) do
          conn
          |> clear_session
          |> configure_session(renew: true)
          |> put_session(:role_session_token, session.token)
          |> put_session(:live_socket_id, "roles_socket:#{session.role_id}")
          |> redirect(to: next_url)
        else
          _err ->
            {:error, :internal_server_error}
        end

      _ ->
        {:error, :forbidden}
    end
  end

  def logout(conn, _params) do
    conn
    |> expire_role_session
    |> clear_session
    |> configure_session(renew: true)
    |> assign(:role, nil)
    |> assign(:role_session, nil)
    |> render("logout.html")
  end

  defp expire_role_session(%{assigns: %{role_session: session}} = conn)
       when not is_nil(session) do
    {:ok, _session} = Auth.expire_session(session)

    :ok =
      VacEngineWeb.Endpoint.broadcast(
        "roles_socket:#{session.role_id}",
        "disconnect",
        %{}
      )

    conn
  end

  defp expire_role_session(conn), do: conn
end
