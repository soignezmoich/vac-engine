defmodule VacEngineWeb.SimulationLive.StackEditorComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngine.Simulation.Job
  alias VacEngineWeb.SimulationLive.StackInputComponent
  alias VacEngineWeb.SimulationLive.StackOutputComponent

  def mount(socket) do
    socket = socket |> assign(results: nil)

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
    socket = socket |> assign(results: job.result.entries)
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

    # stack_case = Simulation.get_stack_id_case(stack_id)

    # data =
    #   case assigns.stack.layers |> Enum.find(&(&1.position == 1)) do
    #     nil -> %{case_id: nil}
    #     layer -> %{case_id: layer.case_id}
    #   end

    # types = %{case_id: :integer}

    # changeset = {data, types} |> cast(%{}, Map.keys(types))

    # kase =
    #   case Simulation.get_stack_case(assigns.stack) do
    #     %Case{} = kase -> kase
    #     _ -> nil
    #   end

    # template =
    #   case Simulation.get_stack_template_case(assigns.stack) do
    #     %Case{} = template -> template
    #     _ -> nil
    #   end

    # {
    #   :ok,
    #   socket
    #   |> assign(assigns)
    #   |> assign(
    #     changeset: changeset,
    #     case: kase,
    #     template: template
    #   )
    # }

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
