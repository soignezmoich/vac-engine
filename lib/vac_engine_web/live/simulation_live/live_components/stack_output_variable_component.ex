defmodule VacEngineWeb.SimulationLive.StackOutputVariableComponent do
  use VacEngineWeb, :live_component

  import VacEngineWeb.IconComponent

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.StackEditorComponent
  alias VacEngineWeb.SimulationLive.ToggleEntryComponent
  alias VacEngineWeb.SimulationLive.ToggleForbiddenComponent
  alias VacEngineWeb.SimulationLive.ExpectedFieldComponent
  alias VacEngineWeb.SimulationLive.VariableFullNameComponent

  def update(
        %{
          id: id,
          filter: filter,
          runnable_case: runnable_case,
          stack: stack,
          variable: variable
        },
        socket
      ) do
    runnable_output_entry =
      runnable_case.output_entries
      |> Enum.find(&(&1.key == variable.path |> Enum.join(".")))

    {expected, forbidden} =
      case runnable_output_entry do
        nil ->
          {nil, false}

        entry ->
          {entry.expected, entry.forbid}
      end

    actual = Enum.random([nil, "2000-01-01"])

    bg_color =
      case Map.get(variable, :match?) do
        false -> "bg-red-100"
        true -> "bg-purple-100"
        _ -> ""
      end

    active = !is_nil(runnable_output_entry)

    visible =
      active ||
        filter == "all"

    socket =
      socket
      |> assign(
        active: active,
        actual: actual,
        expected: expected,
        forbidden: forbidden,
        id: id,
        bg_color: bg_color,
        runnable_case: runnable_case,
        runnable_output_entry: runnable_output_entry,
        stack: stack,
        variable: variable,
        visible: visible
      )

    {:ok, socket}
  end

  def handle_event("toggle_entry", %{"active" => active}, socket) do
    %{
      runnable_case: runnable_case,
      runnable_output_entry: runnable_output_entry,
      stack: stack,
      variable: variable
    } = socket.assigns

    if active == "true" do
      entry_key = variable.path |> Enum.join(".")

      {:ok, input_entry} =
        Simulation.create_blank_output_entry(
          runnable_case,
          entry_key,
          variable
        )

      input_entry
    else
      Simulation.delete_output_entry(runnable_output_entry)
      nil
    end

    send_update(StackEditorComponent,
      id: "stack_editor_#{stack.id}",
      action: {:refresh, :rand.uniform()}
    )

    {:noreply, socket}
  end

  def handle_event(
        "toggle_forbidden",
        %{"forbidden" => forbidden_string},
        socket
      ) do
    %{
      runnable_output_entry: runnable_output_entry,
      stack: stack
    } = socket.assigns

    forbidden =
      case forbidden_string do
        "true" ->
          true

        "false" ->
          false

        _ ->
          throw({:invalid_bool, "can't parse #{forbidden_string} to boolean"})
      end

    runnable_output_entry |> Simulation.toggle_forbidden(forbidden)

    send_update(StackEditorComponent,
      id: "stack_editor_#{stack.id}",
      action: {:refresh, :rand.uniform()}
    )

    {:noreply, socket}
  end
end
