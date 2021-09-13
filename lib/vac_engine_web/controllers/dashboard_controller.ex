defmodule VacEngineWeb.DashboardController do
  use VacEngineWeb, :controller

  action_fallback(VacEngineWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
