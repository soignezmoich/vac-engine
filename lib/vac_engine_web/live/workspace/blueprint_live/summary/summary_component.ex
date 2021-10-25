defmodule VacEngineWeb.Workspace.BlueprintLive.SummaryComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint

  @impl true
  def update(assigns, socket) do
    changeset =
      assigns.blueprint
      |> Processor.change_blueprint()
      |> Map.put(:action, :insert)

    {:ok,
     assign(socket,
       changeset: changeset,
       blueprint: assigns.blueprint,
       role: assigns.role
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
        {:noreply,
         socket
         |> push_redirect(
           to:
             Routes.workspace_blueprint_path(
               socket,
               :summary,
               br.workspace_id,
               br.id
             )
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
