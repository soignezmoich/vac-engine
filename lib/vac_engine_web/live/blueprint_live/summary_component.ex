defmodule VacEngineWeb.BlueprintLive.SummaryComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers
  import VacEngineWeb.InfoComponent

  alias VacEngine.Processor
  alias VacEngine.Pub
  alias VacEngine.Pub.Portal
  alias VacEngineWeb.BlueprintLive.DuplicateButtonComponent
  alias VacEngineWeb.BlueprintLive.ImportComponent

  @impl true
  def update(assigns, socket) do
    changeset =
      assigns.blueprint
      |> Processor.change_blueprint()
      |> Map.put(:action, :insert)

    portal_changeset = %Portal{} |> Pub.change_portal()

    socket
    |> assign(
      can_read_portals:
        can?(assigns.role, :read_portals, assigns.blueprint.workspace),
      changeset: changeset,
      blueprint: assigns.blueprint,
      can_write: assigns.can_write,
      readonly: assigns.readonly,
      role: assigns.role,
      portal_changeset: portal_changeset
    )
    |> ok()
  end

  @impl true
  def handle_event(
        "validate",
        %{"blueprint" => params},
        socket
      ) do
    changeset =
      socket.assigns.blueprint
      |> Processor.change_blueprint(params)
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset)
    |> noreply()
  end

  def handle_event("validate", _params, socket) do
    socket |> noreply()
  end

  @impl true
  def handle_event(
        "update",
        %{"blueprint" => params},
        %{assigns: %{blueprint: blueprint}} = socket
      ) do
    can!(socket, :write, blueprint)

    Processor.update_blueprint(blueprint, params)
    |> case do
      {:ok, _br} ->
        send(self(), :reload_blueprint)
        {:noreply, socket}

      {:error, changeset} ->
        socket
        |> assign(changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event(
        "validate_portal",
        %{"portal" => params},
        socket
      ) do
    changeset =
      %Portal{}
      |> Pub.change_portal(params)
      |> Map.put(:action, :update)

    socket
    |> assign(portal_changeset: changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "publish_new_portal",
        %{"portal" => params},
        %{assigns: %{blueprint: blueprint}} = socket
      ) do
    can!(socket, :write_portals, blueprint.workspace)
    can!(socket, :write, blueprint)

    blueprint
    |> Pub.publish_blueprint(params)
    |> case do
      {:ok, _pub} ->
        socket
        |> push_redirect(
          to:
            Routes.workspace_blueprint_path(
              socket,
              :summary,
              blueprint.workspace_id,
              blueprint.id
            )
        )
        |> noreply()

      _err ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event(
        "delete",
        _,
        %{assigns: %{blueprint: blueprint}} = socket
      ) do
    can!(socket, :write, blueprint)

    {:ok, _} = Processor.delete_blueprint(blueprint)

    socket
    |> push_redirect(
      to:
        Routes.workspace_blueprint_path(socket, :index, blueprint.workspace_id),
      replace: true
    )
    |> noreply()
  end
end
