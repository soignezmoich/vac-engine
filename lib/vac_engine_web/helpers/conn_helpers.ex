defmodule VacEngineWeb.ConnHelpers do
  @moduledoc false

  import Plug.Conn

  def session_attrs(conn) do
    ua = conn |> get_req_header("user-agent")

    %{
      "last_active_at" => NaiveDateTime.utc_now(),
      "remote_ip" => conn.remote_ip,
      "client_info" => %{"user-agent" => ua}
    }
  end
end
