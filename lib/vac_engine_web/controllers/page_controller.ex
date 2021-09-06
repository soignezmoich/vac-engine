defmodule VacEngineWeb.PageController do
  use VacEngineWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
