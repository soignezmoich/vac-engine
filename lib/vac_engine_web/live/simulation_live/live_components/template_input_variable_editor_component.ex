defmodule VacEngineWeb.SimulationLive.TemplateInputVariableEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngineWeb.SimulationLive.InputComponent

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.SimulationEditorComponent
  alias VacEngineWeb.SimulationLive.ToggleEntryComponent

  def update(assigns, socket) do

    IO.puts("UPDATIN TemplateInputVariableComponent")

    input_entry =
      assigns.template.input_entries
      |> Enum.find(&(&1.key == assigns.variable.path |> Enum.join(".")))

    {:ok,
     assign(socket,
       template: assigns.template,
       input_entry: input_entry,
       variable: assigns.variable,
       blueprint: assigns.blueprint,
       value: "placeholder value"
     )}
  end

  def handle_event("set_entry", %{"active" => active}, socket) do

    template = socket.assigns.template
    blueprint = socket.assigns.blueprint

    input_entry = if (active == "true") do
      entry_key = socket.assigns.variable.path |> Enum.join(".")
      {:ok, input_entry} = Simulation.create_input_entry(template, entry_key)
      input_entry
    else
      Simulation.delete_input_entry(socket.assigns.input_entry)
      nil
    end

    send_update(SimulationEditorComponent,
      id: "simulation_editor",
      selected_element: template,
      blueprint: blueprint,
      templates: Simulation.get_templates(blueprint)
    )
    {:noreply, socket}
  end

  def handle_event("update_entry", %{"value" => value}, socket) do

  end
end
