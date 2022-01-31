defmodule VacEngineWeb.SimulationLive.StackEditorComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation

  alias VacEngineWeb.SimulationLive.StackInputComponent
  alias VacEngineWeb.SimulationLive.StackOutputComponent

  def update(
        %{action: {:refresh, _token}},
        %{assigns: %{stack: stack}} = socket
      ) do
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
        %{
          stack_id: stack_id,
          template_names: template_names
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
       runnable_case: runnable_case,
       template_case: template_case,
       template_names: template_names
     )}
  end
end
