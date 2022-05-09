defmodule VacEngineWeb.SimulationLive.StackEditorComponent do
  @moduledoc false

  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias VacEngine.Simulation
  alias VacEngine.Simulation.Job
  alias VacEngineWeb.SimulationLive.CaseNameComponent
  alias VacEngineWeb.SimulationLive.StackEditorComponent
  alias VacEngineWeb.SimulationLive.StackInputComponent
  alias VacEngineWeb.SimulationLive.StackOutputComponent
  alias VacEngineWeb.SimulationLive.MenuStackItemComponent

  def mount(socket) do
    socket
    |> assign(results: %{}, causes_error: false)
    |> ok()
  end

  def update(
        %{action: {:refresh, _token}},
        %{assigns: %{stack: stack}} = socket
      ) do
    Job.new(stack)
    |> Simulation.queue_job()

    socket
    |> load_stack(stack)
    |> ok()
  end

  def update(%{action: {:job_finished, job}}, socket) do
    {causes_error, results} =
      case job.result do
        %{run_error: run_error} when not is_nil(run_error) -> {true, %{}}
        %{entries: entries} -> {false, entries}
      end

    socket
    |> assign(causes_error: causes_error, results: results)
    |> ok()
  end

  def update(
        %{
          stack_id: stack_id,
          template_names: template_names,
          input_variables: input_variables,
          output_variables: output_variables
        },
        socket
      ) do
    stack = Simulation.get_stack(stack_id)

    stack
    |> Job.new()
    |> Simulation.queue_job()

    socket
    |> load_stack(stack)
    |> assign(
      input_variables: input_variables,
      output_variables: output_variables,
      template_names: template_names
    )
    |> ok()
  end

  def handle_event("duplicate_case", _params, socket) do
    %{stack: stack, runnable_case: runnable_case} = socket.assigns
    new_name = "#{runnable_case.name}-b#{stack.blueprint_id}"
    Simulation.fork_runnable_case(stack, new_name)

    send_update(MenuStackItemComponent,
      id: "menu_stack_item_#{stack.id}",
      action: {:refresh, new_name}
    )

    socket
    |> load_stack(stack)
    |> noreply()
  end

  defp load_stack(socket, stack) do
    stack = Simulation.get_stack(stack.id)
    template_case = Simulation.get_stack_template_case(stack)
    runnable_case = Simulation.get_stack_runnable_case(stack)
    stacks_sharing_case = Simulation.get_blueprints_sharing_runnable_case(stack)

    socket
    |> assign(
      stack: stack,
      stacks_sharing_case: stacks_sharing_case,
      shared_case?: Enum.count(stacks_sharing_case) > 0,
      runnable_case: runnable_case,
      template_case: template_case,
      target_components: make_target_components(stack)
    )
  end

  defp make_target_components(stack) do
    [
      %{
        type: StackEditorComponent,
        id: "stack_editor_#{stack.id}"
      },
      %{
        type: MenuStackItemComponent,
        id: "menu_stack_item_#{stack.id}"
      }
    ]
  end
end
