defmodule VacEngineWeb.Workspace.PortalLive.Index do
  use VacEngineWeb, :live_view

  alias VacEngine.Pub
  alias VacEngine.EnumHelpers
  alias VacEngine.Pub.Portal

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(workspace pub)a})

  @impl true
  def mount(
        _params,
        _session,
        %{assigns: %{workspace: workspace, role: role}} = socket
      ) do
    can!(socket, :publish, workspace)
    portals = Pub.load_portals(workspace).portals
    {:ok, assign(socket, portals: portals)}
  end

  @impl true
  def handle_event(
        "delete",
        %{"id" => id},
        %{assigns: %{workspace: workspace, role: role, portals: portals}} =
          socket
      ) do
    {id, _} = Integer.parse(id)

    portals
    |> EnumHelpers.find_by(:id, id)
    |> case do
      nil ->
        {:noreply, socket}

      portal ->
        can!(socket, :delete, portal)
        {:ok, _} = Pub.delete_portal(portal)
        portals = Pub.load_portals(workspace, true).portals
        {:noreply, assign(socket, portals: portals)}
    end
  end
end
