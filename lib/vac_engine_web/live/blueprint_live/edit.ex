defmodule VacEngineWeb.BlueprintLive.Edit do
  use VacEngineWeb, :live_view

  import VacEngineWeb.PermissionHelpers

  alias Phoenix.PubSub
  alias VacEngine.Processor
  alias VacEngineWeb.BlueprintLive.SummaryComponent
  alias VacEngineWeb.BlueprintLive.ImportComponent
  alias VacEngineWeb.EditorLive.DeductionEditorComponent
  alias VacEngineWeb.EditorLive.VariableEditorComponent
  alias VacEngineWeb.SimulationLive.SimulationEditorComponent
  alias VacEngineWeb.SimulationLive.SimulationEditorTestComponent

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(blueprint edit)a})

  @impl true
  def mount(%{"blueprint_id" => blueprint_id}, _session, socket) do
    blueprint = get_blueprint!(blueprint_id, socket)

    can!(socket, :read, blueprint)

    {:ok,
     assign(socket,
       blueprint: blueprint,
       can_write: can?(socket, :write, blueprint)
     )}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    socket
    |> assign(location: [:blueprint, socket.assigns.live_action])
    |> update_subscription()

    {:noreply, socket}
  end

  @impl true
  def handle_info({:update_blueprint, br}, socket) do
    {:noreply, assign(socket, blueprint: br)}
  end

  @impl true
  def handle_info(:reload_blueprint, socket) do
    {:noreply,
     assign(socket,
       blueprint:
         get_blueprint!(
           socket.assigns.blueprint.id,
           socket
         )
     )}
  end

  @impl true
  def handle_info({:job_finished, job}, socket) do
    send_update(VacEngineWeb.SimulationLive.StackEditorComponent,
      id: "stack_editor_#{job.stack_id}",
      action: {:job_finished, job}
    )

    send_update(VacEngineWeb.SimulationLive.MenuStackItemComponent,
      id: "menu_stack_item_#{job.stack_id}",
      action: {:job_finished, job}
    )

    {:noreply, socket}
  end

  def get_blueprint!(id, socket) do
    if connected?(socket) do
      Processor.get_blueprint!(id, fn query ->
        query
        |> Processor.load_blueprint_active_publications()
        |> Processor.load_blueprint_inactive_publications()
        |> Processor.load_blueprint_variables()
        |> Processor.load_blueprint_full_deductions()
      end)
    else
      Processor.get_blueprint!(id)
    end
  end

  defp update_subscription(socket) do
    socket
    |> unsubscribe()
    |> subscribe()
  end

  defp unsubscribe(%{assigns: %{subscribed_topic: topic}} = socket)
       when not is_nil(topic) do
    PubSub.unsubscribe(:simulation, topic)
    socket |> assign(subscribed_topic: nil)
  end

  defp unsubscribe(socket) do
    socket
  end

  defp subscribe(%{assigns: %{blueprint: blueprint}} = socket) do
    topic = "blueprint:#{blueprint.id}"
    PubSub.subscribe(VacEngine.PubSub, topic)

    socket |> assign(subscribed_topic: topic)
  end

  defp subscribe(socket) do
    socket
  end
end
