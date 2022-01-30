defmodule VacEngineWeb.SimulationLive.StackInputVariableComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.EntryValueFieldComponent
  alias VacEngineWeb.SimulationLive.SimulationEditorComponent
  alias VacEngineWeb.SimulationLive.ToggleEntryComponent

  def update(assigns, socket) do
    template_input_entry =
      assigns.template
      |> case do
        nil ->
          nil

        template ->
          template.input_entries
          |> Enum.find(&(&1.key == assigns.variable.path |> Enum.join(".")))
      end

    # IO.inspect(template_input_entry)

    input_entry =
      assigns.case.input_entries
      |> Enum.find(&(&1.key == assigns.variable.path |> Enum.join(".")))

    bg_color =
      case {input_entry, template_input_entry} do
        {nil, nil} -> ""
        {nil, _} -> "bg-purple-50"
        _ -> "bg-purple-100"
      end

    {:ok,
     assign(socket,
       template: assigns.template,
       input_entry: input_entry,
       template_input_entry: template_input_entry,
       variable: assigns.variable,
       blueprint: assigns.blueprint,
       stack: assigns.stack,
       filter: assigns.filter,
       bg_color: bg_color,
       case: assigns.case,
       value: "placeholder value"
     )}
  end

  def handle_event("set_entry", %{"active" => active}, socket) do
    kase = socket.assigns.case
    stack = socket.assigns.stack
    blueprint = socket.assigns.blueprint

    if active == "true" do
      IO.puts("ACTIVE")
      type = socket.assigns.variable.type
      enum = Map.get(socket.assigns.variable, :enum)

      entry_key = socket.assigns.variable.path |> Enum.join(".")

      IO.puts("ENTRY KEY:")
      IO.inspect(entry_key)

      {:ok, _input_entry} =
        Simulation.create_input_entry(
          kase,
          entry_key,
          Simulation.variable_default_value(type, enum)
        )
    else
      Simulation.delete_input_entry(socket.assigns.input_entry)
    end

    IO.puts("BEFORE SEND")

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
