defmodule VacEngineWeb.Workspace.PortalLive.Edit do
  use VacEngineWeb, :live_view

  alias VacEngine.Pub
  alias VacEngine.Pub.Portal
  alias VacEngine.Processor

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(workspace portal)a})

  @impl true
  def mount(
        %{"portal_id" => portal_id},
        _session,
        socket
      ) do
    portal =
      Pub.get_portal!(portal_id, fn query ->
        query
        |> Pub.load_portal_publications()
      end)

    can!(socket, :edit, portal)

    changeset =
      portal
      |> Pub.change_portal()
      |> Map.put(:action, :update)

    {:ok,
     assign(socket,
       portal: portal,
       changeset: changeset,
       blueprint_results: [],
       search_blueprint_visible: false
     )}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
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
       to: Routes.workspace_portal_path(socket, :index, workspace),
       replace: true
     )}
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
        "update",
        %{"portal" => params},
        %{assigns: %{portal: portal}} = socket
      ) do
    can!(socket, :edit, portal)

    Pub.update_portal(portal, params)
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

  @impl true
  def handle_event(
        "toggle_search_blueprint",
        _,
        %{assigns: %{search_blueprint_visible: visibility}} = socket
      ) do
    {:noreply,
     socket
     |> assign(search_blueprint_visible: !visibility)}
  end

  @impl true
  def handle_event(
        "search_blueprints",
        %{"query" => %{"query" => search}},
        %{
          assigns: %{
            search_blueprint_visible: true,
            workspace: workspace,
            portal: portal
          }
        } = socket
      )
      when is_binary(search) and byte_size(search) > 0 do
    can!(socket, :edit, portal)
    can!(socket, :edit, workspace)

    results =
      Processor.list_blueprints(fn query ->
        query
        |> Processor.filter_blueprints_by_workspace(workspace)
        |> Processor.filter_blueprints_by_query(search)
        |> Processor.limit_blueprints(10)
      end)

    {:noreply, assign(socket, blueprint_results: results)}
  end

  @impl true
  def handle_event("search_blueprints", _, socket) do
    {:noreply, assign(socket, blueprint_results: [])}
  end

  @impl true
  def handle_event(
        "publish",
        %{"id" => br_id},
        %{
          assigns: %{
            workspace: workspace,
            portal: portal
          }
        } = socket
      ) do
    can!(socket, :edit, portal)
    can!(socket, :edit, workspace)

    {br_id, ""} = Integer.parse(br_id)

    blueprint =
      Processor.get_blueprint!(br_id, fn query ->
        query
        |> Processor.filter_blueprints_by_workspace(workspace)
      end)

    can!(socket, :publish, blueprint)

    {:ok, _pub} = Pub.publish_blueprint(blueprint, portal)

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
  end
end
