defmodule VacEngineWeb.PortalLive.New do
  use VacEngineWeb, :live_view

  alias VacEngine.Pub
  alias VacEngine.Pub.Portal

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(workspace portal)a})

  @impl true
  def mount(_params, _session, %{assigns: %{workspace: workspace}} = socket) do
    can!(socket, :write_portals, workspace)

    changeset =
      %Portal{}
      |> Pub.change_portal()
      |> Map.put(:action, :insert)

    {:ok, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{"portal" => params},
        socket
      ) do
    changeset =
      %Portal{}
      |> Pub.change_portal(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event(
        "create",
        %{"portal" => params},
        %{assigns: %{workspace: workspace}} = socket
      ) do
    can!(socket, :write_portals, workspace)

    Pub.create_portal(workspace, params)
    |> case do
      {:ok, portal} ->
        {:noreply,
         socket
         |> push_redirect(
           to:
             Routes.workspace_portal_path(
               socket,
               :edit,
               portal.workspace_id,
               portal.id
             )
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
