defmodule VacEngineWeb.BlueprintLive.Index do
  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers

  alias VacEngine.Processor
  alias VacEngine.Query

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(blueprint index)a})

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
        |> Processor.filter_accessible_blueprints(role)
        |> Processor.load_blueprint_active_publications()
        |> Query.order_by(:id)
      end)

    socket
    |> assign(
      blueprints: blueprints,
      can_read_portals: can?(socket, :read_portals, workspace)
    )
    |> ok()
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("duplicate", %{"blueprint_id" => blueprint_id}, socket) do
    %{workspace: workspace} = socket.assigns

    {:ok, new_blueprint} =
      Processor.duplicate_blueprint(blueprint_id, workspace)

    socket =
      push_redirect(socket,
        to:
          Routes.workspace_blueprint_path(
            socket,
            :summary,
            workspace.id,
            new_blueprint.id
          )
      )

    {:noreply, socket}
  end
end
