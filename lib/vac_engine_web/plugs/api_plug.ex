defmodule VacEngineWeb.ApiPlug do
  import Plug.Conn

  @err Jason.encode!(%{error: "unauthorized, api_key required"})

  def require_api_key(conn, _) do
    with ["Bearer " <> api_key] <- get_req_header(conn, "authorization") do
      assign(conn, :api_key, api_key)
    else
      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> resp(401, @err)
        |> halt()
    end
  end
end
