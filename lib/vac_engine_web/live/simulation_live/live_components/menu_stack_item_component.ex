defmodule VacEngineWeb.SimulationLive.MenuStackItemComponent do
  use VacEngineWeb, :live_component

  import VacEngineWeb.IconComponent

  import VacEngine.PipeHelpers
  alias VacEngine.Simulation
  alias VacEngine.Simulation.Job
  alias VacEngine.Simulation.Stack
  alias VacEngineWeb.SimulationLive.MenuStackListComponent
  alias VacEngineWeb.SimulationLive.SimulationEditorComponent

  @impl true
  def mount(socket) do
    socket |> assign(outcome: :not_tested) |> ok()
  end

  @impl true
  def update(
        %{
          id: id,
          blueprint_id: blueprint_id,
          stack_id: stack_id,
          stack_name: stack_name,
          selected: selected
        },
        socket
      ) do
    %Stack{id: stack_id, blueprint_id: blueprint_id}
    |> Job.new()
    |> Simulation.queue_job()

    socket
    |> assign(
      id: id,
      stack_id: stack_id,
      stack_name: stack_name,
      selected: selected
    )
    |> ok()
  end

  def update(%{action: {:job_finished, %Job{} = job}}, socket) do
    outcome =
      if job.result.has_error || !job.result.result_match do
        :failure
      else
        :success
      end

    socket
    |> assign(outcome: outcome)
    |> ok()
  end

  @impl true
  def handle_event("select_item", _params, socket) do
    send_update(SimulationEditorComponent,
      id: "simulation_editor",
      action: :set_selection,
      selected_type: :stack,
      selected_id: socket.assigns.stack_id
    )

    {:noreply, socket}
  end

  def handle_event("delete_stack", _params, socket) do
    %{stack_id: stack_id} = socket.assigns

    Simulation.delete_stack(stack_id)

    send_update(MenuStackListComponent,
      id: "menu_stack_list",
      action: :refresh_after_delete_stack,
      stack_id: stack_id
    )

    send_update(SimulationEditorComponent,
      id: "simulation_editor",
      action: :set_selection,
      selected_type: nil,
      selected_id: nil
    )

    {:noreply, socket}
  end
end
