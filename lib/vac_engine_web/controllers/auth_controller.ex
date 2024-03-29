defmodule VacEngineWeb.AuthController do
  @moduledoc """
  Authentication controller.
  """

  use VacEngineWeb, :controller

  import VacEngineWeb.ConnHelpers
  alias VacEngine.Account

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
        user = Account.get_user!(user_id, &Account.load_user_role/1)

        {:ok, session} = Account.create_session(user.role, session_attrs(conn))

        conn
        |> clear_session
        |> configure_session(renew: true)
        |> put_session(:role_session_token, session.token)
        |> put_session(:live_socket_id, "roles_socket:#{session.role_id}")
        |> redirect(to: next_url)

      _ ->
        {:error, :forbidden}
    end
  end

  def logout(conn, _params) do
    conn
    |> revoke_role_session
    |> clear_session
    |> configure_session(renew: true)
    |> assign(:role, nil)
    |> assign(:role_session, nil)
    |> render("logout.html")
  end

  defp revoke_role_session(%{assigns: %{role_session: session}} = conn)
       when not is_nil(session) do
    {:ok, _session} = Account.revoke_session(session)

    :ok = VacEngineWeb.Endpoint.disconnect_live_views(session)

    conn
  end

  defp revoke_role_session(conn), do: conn
end
