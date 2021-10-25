defmodule VacEngineWeb.Workspace.BlueprintLive.SummaryComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Pub.Publication
  alias VacEngine.Pub.Portal
  alias VacEngine.Pub

  @impl true
  def update(assigns, socket) do
    changeset =
      assigns.blueprint
      |> Processor.change_blueprint()
      |> Map.put(:action, :insert)

    publications = Pub.load_publications(assigns.blueprint).publications

    portal_changeset = %Portal{} |> Pub.change_portal()

    {:ok,
     assign(socket,
       changeset: changeset,
       blueprint: assigns.blueprint,
       role: assigns.role,
       publications: publications,
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
        %{assigns: %{blueprint: blueprint}} = socket
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
            publications = Pub.load_publications(blueprint).publications
            changeset = %Portal{} |> Pub.change_portal()

            {:noreply,
             assign(socket,
               publications: publications,
               portal_changeset: changeset
             )}

          err ->
            {:noreply, socket}
        end
    end
  end
end
