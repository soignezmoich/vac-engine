defmodule VacEngineWeb.WelcomeController do
  @doc """
  Handles the root route.
  """

  use VacEngineWeb, :controller

  action_fallback(VacEngineWeb.FallbackController)

  def index(%{assigns: %{workspaces: [w | _]}} = conn, _params) do
    conn
    |> redirect(to: Routes.workspace_blueprint_path(conn, :index, w.id))
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
