defmodule VacEngineWeb.SimulationLive.StackEditorComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngine.Simulation.Job
  alias VacEngineWeb.SimulationLive.StackInputComponent
  alias VacEngineWeb.SimulationLive.StackOutputComponent

  def mount(socket) do
    socket = socket |> assign(results: %{}, causes_error: false)

    {:ok, socket}
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

    socket =
      socket
      |> assign(
        stack: stack,
        runnable_case: runnable_case,
        template_case: template_case
      )

    {:ok, socket}
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

    socket = socket |> assign(causes_error: causes_error, results: results)
    {:ok, socket}
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

    {:ok,
     socket
     |> assign(
       stack: stack,
       input_variables: input_variables,
       output_variables: output_variables,
       runnable_case: runnable_case,
       template_case: template_case,
       template_names: template_names
     )}
  end
end
