defmodule VacEngineWeb.BlueprintLive.SummaryComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Processor
  alias VacEngine.Pub.Portal
  alias VacEngine.Pub

  @impl true
  def update(assigns, socket) do
    changeset =
      assigns.blueprint
      |> Processor.change_blueprint()
      |> Map.put(:action, :insert)

    portal_changeset = %Portal{} |> Pub.change_portal()

    {:ok,
     assign(socket,
       can_read_portals:
         can?(assigns.role, :read_portals, assigns.blueprint.workspace),
       changeset: changeset,
       blueprint: assigns.blueprint,
       can_write: assigns.can_write,
       role: assigns.role,
       portal_changeset: portal_changeset
     )}
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

    {:noreply, assign(socket, changeset: changeset)}
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
      {:ok, br} ->
        send(self(), :reload_blueprint)
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
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

    {:noreply, assign(socket, portal_changeset: changeset)}
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
        {:noreply,
         socket
         |> push_redirect(
           to:
             Routes.workspace_blueprint_path(
               socket,
               :summary,
               blueprint.workspace_id,
               blueprint.id
             )
         )}

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

    {:noreply,
     socket
     |> push_redirect(
       to:
         Routes.workspace_blueprint_path(socket, :index, blueprint.workspace_id),
       replace: true
     )}
  end
end
