defmodule VacEngineWeb.SimulationLive.StackEditorComponent do
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

    stack = Simulation.get_stack(stack.id)
    template_case = stack |> Simulation.get_stack_template_case()
    runnable_case = stack |> Simulation.get_stack_runnable_case()

    socket
    |> assign(
      stack: stack,
      runnable_case: runnable_case,
      template_case: template_case,
      target_components: make_target_components(stack)
    )
    |> ok()
  end

  def update(
        %{action: {:job_finished, job}},
        socket
      ) do
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

    template_case = stack |> Simulation.get_stack_template_case()
    runnable_case = stack |> Simulation.get_stack_runnable_case()

    stack
    |> Job.new()
    |> Simulation.queue_job()

    socket
    |> assign(
      stack: stack,
      input_variables: input_variables,
      output_variables: output_variables,
      runnable_case: runnable_case,
      template_case: template_case,
      template_names: template_names,
      target_components: make_target_components(stack)

    )
    |> ok()
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
