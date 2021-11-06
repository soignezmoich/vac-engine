defmodule VacEngineWeb.Workspace.BlueprintLive.SummaryComponent do
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
       changeset: changeset,
       blueprint: assigns.blueprint,
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
    can!(socket, :update, :blueprint)

    Processor.update_blueprint(blueprint, params)
    |> case do
      {:ok, br} ->
        send(self(), {:update_blueprint, br})
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
    can!(socket, :publish, :blueprint)

    %Portal{}
    |> Pub.change_portal(params)
    |> Map.put(:action, :update)
    |> case do
      %{valid?: false} = ch ->
        {:noreply, assign(socket, portal_changeset: ch)}

      ch ->
        Pub.publish_blueprint(blueprint, ch.changes)
        |> case do
          {:ok, pub} ->
            blueprint = %{
              blueprint
              | active_publications: [pub | blueprint.active_publications]
            }

            changeset = %Portal{} |> Pub.change_portal()

            {:noreply,
             assign(socket,
               blueprint: blueprint,
               portal_changeset: changeset
             )}

          _err ->
            {:noreply, socket}
        end
    end
  end

  @impl true
  def handle_event(
        "delete",
        _,
        %{assigns: %{blueprint: blueprint}} = socket
      ) do
    can!(socket, :delete, blueprint)

    {:ok, _} = Processor.delete_blueprint(blueprint)

    {:noreply,
     socket
     |> push_redirect(
       to:
         Routes.workspace_blueprint_path(socket, :index, blueprint.workspace_id)
     )}
  end
end
