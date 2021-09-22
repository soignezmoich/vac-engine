defmodule VacEngineWeb.AuthControllerTest do
  use VacEngineWeb.ConnCase

  alias VacEngine.Accounts
  alias VacEngine.Accounts.Session
  alias VacEngine.Repo

  test "GET /login", %{conn: conn} do
    conn = get(conn, "/login")
    assert html_response(conn, 200) =~ "Login"
  end

  test "GET /login/:token FAIL", %{conn: conn} do
    conn = get(conn, "/login/12345")
    assert html_response(conn, 403) =~ "Access denied"
  end

  test "GET /login/:token SUCCESS", %{conn: conn} do
    assert {:ok, %{user: user}} =
             Accounts.create_user(%{
               email: "test@test.com",
               name: "Jon Doe",
               password: "12341234"
             })

    token =
      Phoenix.Token.sign(
        VacEngineWeb.Endpoint,
        "login_token",
        {user.id, "/next"}
      )

    conn = get(conn, "/login/#{token}")
    assert redirected_to(conn) == "/next"

    assert [session] = Repo.all(Session)
    assert false == Session.expired?(session)

    conn = get(conn, "/logout")
    assert html_response(conn, 200) =~ "Logout"
    assert [session] = Repo.all(Session)
    assert true == Session.expired?(session)
  end
end
