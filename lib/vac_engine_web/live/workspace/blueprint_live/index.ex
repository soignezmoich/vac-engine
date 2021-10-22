defmodule VacEngineWeb.Workspace.BlueprintLive.Index do
  use VacEngineWeb, :live_view

  alias VacEngine.Processor

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(workspace blueprint index)a})

  @impl true
  def mount(_params, _session, socket) do
    workspace = socket.assigns.workspace

    blueprints = Processor.list_blueprints(workspace)
    {:ok, assign(socket, blueprints: blueprints)}
  end
end
