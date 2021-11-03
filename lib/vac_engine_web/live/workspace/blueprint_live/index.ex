defmodule VacEngineWeb.Workspace.BlueprintLive.Index do
  use VacEngineWeb, :live_view

  import VacEngineWeb.BlueprintsListComponent

  alias VacEngine.Account

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(workspace blueprint index)a})

  @impl true
  def mount(_params, _session, socket) do
    workspace = socket.assigns.workspace

    blueprints = Account.load_blueprints(workspace).blueprints
    {:ok, assign(socket, blueprints: blueprints)}
  end
end
