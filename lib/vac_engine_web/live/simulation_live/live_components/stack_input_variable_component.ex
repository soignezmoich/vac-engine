defmodule VacEngineWeb.SimulationLive.StackInputVariableComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.EntryValueFieldComponent
  alias VacEngineWeb.SimulationLive.SimulationEditorComponent
  alias VacEngineWeb.SimulationLive.StackEditorComponent
  alias VacEngineWeb.SimulationLive.ToggleEntryComponent


# module={StackInputComponent}
# id={"case_input_#{@stack.id}"}
# input_variables={@input_variables}
# runnable_case={@runnable_case}
# template_case={@template_case}
# stack={@stack}

  def update(%{
    id: id,
    filter: filter,
    runnable_case: runnable_case,
    stack: stack,
    template_case: template_case,
    variable: variable
  }, socket) do

    template_input_entry = case template_case do
      nil ->
          nil

      template_case ->
        template_case.input_entries
        |> Enum.find(&(&1.key == variable.path |> Enum.join(".")))
    end

    runnable_input_entry =
      runnable_case.input_entries
      |> Enum.find(&(&1.key == variable.path |> Enum.join(".")))

    bg_color =
      case {runnable_input_entry, template_input_entry} do
        {nil, nil} -> ""
        {nil, _} -> "bg-purple-50"
        _ -> "bg-purple-100"
      end

    socket =
      socket
      |> assign(
        id: id,
        filter: filter,
        runnable_case: runnable_case,
        runnable_input_entry: runnable_input_entry,
        stack: stack,
        template_case: template_case,
        template_input_entry: template_input_entry,
        variable: variable,
        bg_color: bg_color,
      )

    {:ok, socket}
  end


  def handle_event("toggle_entry", %{"active" => active}, socket) do

    %{
      runnable_case: runnable_case,
      stack: stack,
      runnable_input_entry: runnable_input_entry,
      variable: variable
    } = socket.assigns

    if active == "true" do
      type = variable.type
      enum = Map.get(variable, :enum)

      entry_key = variable.path |> Enum.join(".")

      {:ok, input_entry} =
        Simulation.create_input_entry(
          runnable_case,
          entry_key,
          Simulation.variable_default_value(type, enum)
        )

      input_entry
    else
      Simulation.delete_input_entry(runnable_input_entry)
      nil
    end

    send_update(StackEditorComponent,
      id: "stack_editor_#{stack.id}",
      action: {:refresh, :rand.uniform()}
    )

    {:noreply, socket}
  end

  def handle_event("set_entry", %{"active" => active}, socket) do
    kase = socket.assigns.case
    stack = socket.assigns.stack
    blueprint = socket.assigns.blueprint

    if active == "true" do
      type = socket.assigns.variable.type
      enum = Map.get(socket.assigns.variable, :enum)

      entry_key = socket.assigns.variable.path |> Enum.join(".")

      {:ok, _input_entry} =
        Simulation.create_input_entry(
          kase,
          entry_key,
          Simulation.variable_default_value(type, enum)
        )
    else
      Simulation.delete_input_entry(socket.assigns.input_entry)
    end

    send_update(SimulationEditorComponent,
      id: "simulation_editor",
      selected_element: stack,
      blueprint: blueprint,
      stacks: Simulation.get_stacks(blueprint),
      action: "refresh-#{:rand.uniform()}"
    )

    {:noreply, socket}
  end
end
