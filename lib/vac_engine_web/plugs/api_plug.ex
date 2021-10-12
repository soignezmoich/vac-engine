defmodule VacEngineWeb.ApiPlug do
  import Plug.Conn

  @err Jason.encode!(%{error: "unauthorized, api_key required"})

  def require_api_key(conn, _) do
    conn
    |> get_req_header("authorization")
    |> case do
      ["Bearer " <> api_key] ->
        assign(conn, :api_key, api_key)

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> resp(401, @err)
        |> halt()
    end
  end
end
