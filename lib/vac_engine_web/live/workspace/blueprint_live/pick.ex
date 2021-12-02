defmodule VacEngineWeb.Workspace.BlueprintLive.Pick do
  use VacEngineWeb, :live_view

  alias VacEngine.Processor

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(blueprint pick)a})

  @impl true
  def mount(
        _params,
        _session,
        %{assigns: %{workspace: workspace, role: role}} = socket
      ) do
    blueprints =
      Processor.list_blueprints(fn query ->
        query
        |> Processor.filter_blueprints_by_workspace(workspace)
        |> Processor.load_blueprint_active_publications()
        |> Processor.filter_accessible_blueprints(role)
      end)

    {:ok, assign(socket, blueprints: blueprints)}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end
end
