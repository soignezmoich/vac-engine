defmodule VacEngineWeb.Workspace.BlueprintLive.Index do
  use VacEngineWeb, :live_view

  alias VacEngine.Processor

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(workspace blueprint index)a})

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :super_admin, :global)
    workspace = socket.assigns.workspace

    blueprints =
      Processor.list_blueprints(fn query ->
        query
        |> Processor.filter_blueprints_by_workspace(workspace)
        |> Processor.load_blueprint_active_publications()
      end)

    {:ok, assign(socket, blueprints: blueprints)}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end
end
