defmodule VacEngineWeb.SimulationLive.TemplateInputVariableComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.EntryValueFieldComponent
  alias VacEngineWeb.SimulationLive.TemplateEditorComponent
  alias VacEngineWeb.SimulationLive.ToggleEntryComponent
  alias VacEngineWeb.SimulationLive.VariableFullNameComponent

  def update(
        %{
          id: id,
          filter: filter,
          template: template,
          variable: variable
        },
        socket
      ) do
    input_entry =
      template.case.input_entries
      |> Enum.find(&(&1.key == variable.path |> Enum.join(".")))

    active = !is_nil(input_entry)

    visible = active || filter == "all"

    socket =
      socket
      |> assign(
        id: id,
        active: active,
        template: template,
        input_entry: input_entry,
        variable: variable,
        visible: visible
      )

    {:ok, socket}
  end

  def handle_event("toggle_entry", %{"active" => active}, socket) do
    template = socket.assigns.template

    if active == "true" do
      type = socket.assigns.variable.type
      enum = Map.get(socket.assigns.variable, :enum)

      entry_key = socket.assigns.variable.path |> Enum.join(".")

      {:ok, input_entry} =
        Simulation.create_input_entry(
          template.case,
          entry_key,
          Simulation.variable_default_value(type, enum)
        )

      input_entry
    else
      Simulation.delete_input_entry(socket.assigns.input_entry)
      nil
    end

    send_update(TemplateEditorComponent,
      id: "template_editor_#{socket.assigns.template.id}",
      action: {:refresh, :rand.uniform()}
    )

    {:noreply, socket}
  end
end
