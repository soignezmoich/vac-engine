defmodule VacEngineWeb.SimulationLive.StackInputVariableComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.EntryValueFieldComponent
  alias VacEngineWeb.SimulationLive.StackEditorComponent
  alias VacEngineWeb.SimulationLive.ToggleComponent
  alias VacEngineWeb.SimulationLive.VariableFullNameComponent

  def update(
        %{
          id: id,
          filter: filter,
          runnable_case: runnable_case,
          stack: stack,
          template_case: template_case,
          variable: variable
        },
        socket
      ) do
    template_input_entry =
      case template_case do
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
        {nil, _} -> "bg-blue-50"
        _ -> "bg-blue-100"
      end

    active = !is_nil(runnable_input_entry)

    visible =
      active ||
        (filter == "template" && !is_nil(template_input_entry)) ||
        filter == "all"

    socket
    |> assign(
      id: id,
      active: active,
      runnable_case: runnable_case,
      runnable_input_entry: runnable_input_entry,
      stack: stack,
      template_case: template_case,
      template_input_entry: template_input_entry,
      variable: variable,
      visible: visible,
      bg_color: bg_color
    )
    |> ok()
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
end
