defmodule VacEngineWeb.Workspace.PortalLive.Edit do
  use VacEngineWeb, :live_view

  alias VacEngine.Pub
  alias VacEngine.Pub.Portal

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(workspace pub)a})

  @impl true
  def mount(
        %{"portal_id" => portal_id},
        _session,
        socket
      ) do
    can!(socket, :edit, {:portal, portal_id})

    portal =
      Pub.get_portal!(portal_id)
      |> Pub.load_publications()

    active_publication = Portal.active_publication(portal)

    {:ok,
     assign(socket, portal: portal, active_publication: active_publication)}
  end

  @impl true
  def handle_event(
        "delete",
        _,
        %{assigns: %{workspace: workspace, portal: portal}} = socket
      ) do
    can!(socket, :delete, portal)
    {:ok, _} = Pub.delete_portal(portal)

    {:noreply,
     socket
     |> push_redirect(
       to: Routes.workspace_portal_path(socket, :index, workspace)
     )}
  end
end
