defmodule VacEngineWeb.WelcomeController do
  use VacEngineWeb, :controller

  action_fallback(VacEngineWeb.FallbackController)

  def index(%{assigns: %{workspaces: [w | _]}} = conn, _params) do
    conn
    |> redirect(to: Routes.workspace_dashboard_path(conn, :index, w.id))
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
