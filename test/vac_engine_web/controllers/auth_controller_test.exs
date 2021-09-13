defmodule VacEngineWeb.AuthControllerTest do
  use VacEngineWeb.ConnCase

  test "GET /login", %{conn: conn} do
    conn = get(conn, "/login/12345")
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
