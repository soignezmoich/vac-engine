defmodule VacEngineWeb.PortalLive.Index do
  use VacEngineWeb, :live_view

  alias VacEngine.Pub
  alias VacEngine.Query

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(workspace portal)a})

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

    {:ok, assign(socket, portals: portals)}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end
end
