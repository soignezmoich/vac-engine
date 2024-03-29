defmodule VacEngineWeb.PortalLive.Edit do
  @moduledoc false

  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers

  alias VacEngine.Pub
  alias VacEngine.Query
  alias VacEngine.Pub.Portal
  alias VacEngine.Processor
  alias VacEngineWeb.InlineSearchComponent

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(portal edit)a})

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
        |> Pub.load_portal_blueprint()
      end)

    can!(socket, :read, portal)

    changeset =
      portal
      |> Pub.change_portal()
      |> Map.put(:action, :update)

    socket
    |> assign(
      can_write: can?(socket, :write, portal),
      portal: portal,
      changeset: changeset,
      blueprint_results: []
    )
    |> ok()
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
    can!(socket, :write, portal)
    {:ok, _} = Pub.delete_portal(portal)

    socket
    |> push_redirect(
      to: Routes.workspace_portal_path(socket, :index, workspace),
      replace: true
    )
    |> noreply()
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

    socket
    |> assign(changeset: changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "update",
        %{"portal" => params},
        %{assigns: %{portal: portal}} = socket
      ) do
    can!(socket, :write, portal)

    Pub.update_portal(portal, params)
    |> case do
      {:ok, portal} ->
        socket
        |> push_redirect(
          to:
            Routes.workspace_portal_path(
              socket,
              :edit,
              portal.workspace_id,
              portal.id
            )
        )
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event(
        "search_blueprints",
        %{"query" => %{"query" => search}},
        %{
          assigns: %{
            workspace: workspace,
            portal: portal
          }
        } = socket
      )
      when is_binary(search) and byte_size(search) > 0 do
    can!(socket, :write, portal)

    results =
      Processor.list_blueprints(fn query ->
        query
        |> Processor.filter_blueprints_by_workspace(workspace)
        |> Query.filter_by_query(search)
        |> Query.limit(10)
      end)

    socket
    |> assign(blueprint_results: results)
    |> noreply()
  end

  @impl true
  def handle_event("search_blueprints", _, socket) do
    socket
    |> assign(blueprint_results: [])
    |> noreply()
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
    can!(socket, :write, portal)

    {br_id, ""} = Integer.parse(br_id)

    blueprint =
      Processor.get_blueprint!(br_id, fn query ->
        query
        |> Processor.filter_blueprints_by_workspace(workspace)
      end)

    can!(socket, :read, blueprint)

    {:ok, _pub} = Pub.publish_blueprint(blueprint, portal)

    socket
    |> push_redirect(
      to:
        Routes.workspace_portal_path(
          socket,
          :edit,
          portal.workspace_id,
          portal.id
        )
    )
    |> noreply()
  end

  @impl true
  def handle_event(
        "unpublish",
        _,
        %{
          assigns: %{
            workspace: _workspace,
            portal: portal
          }
        } = socket
      ) do
    can!(socket, :write, portal)

    {:ok, _pub} = Pub.unpublish_portal(portal)

    socket
    |> push_redirect(
      to:
        Routes.workspace_portal_path(
          socket,
          :edit,
          portal.workspace_id,
          portal.id
        )
    )
    |> noreply()
  end
end
