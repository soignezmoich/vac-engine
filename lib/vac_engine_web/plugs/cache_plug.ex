defmodule VacEngineWeb.CachePlug do
  import Plug.Conn

  def no_cache(conn, _) do
    conn
    |> put_resp_header("cache-control", "no-store, private")
    |> put_resp_header("pragma", "no-cache")
  end
end
