defmodule VacEngineWeb.PortalLive.Index do
  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers

  alias VacEngine.Pub
  alias VacEngine.Query

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(portal index)a})

  @impl true
  def mount(
        _params,
        _session,
        %{assigns: %{workspace: workspace, role: role}} = socket
      ) do
    portals =
      Pub.list_portals(fn query ->
        query
        |> Pub.filter_portals_by_workspace(workspace)
        |> Pub.load_portal_blueprint()
        |> Pub.load_portal_publications()
        |> Pub.filter_accessible_portals(role)
        |> Query.order_by(:id)
      end)

    socket
    |> assign(portals: portals)
    |> ok()
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end
end
