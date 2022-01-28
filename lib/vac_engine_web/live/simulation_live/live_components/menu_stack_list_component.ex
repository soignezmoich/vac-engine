defmodule VacEngineWeb.SimulationLive.MenuStackListComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.MenuStackItemComponent
  alias VacEngineWeb.SimulationLive.SimulationEditorComponent

  def update(
        %{
          blueprint: blueprint,
          id: id,
          selected_id: selected_id,
          selected_type: selected_type
        },
        socket
      ) do
    {:ok,
     socket
     |> assign(
       id: id,
       blueprint: blueprint,
       stacks: Simulation.get_stack_names(blueprint),
       selected_id: selected_id,
       has_selection: selected_type == :stack,
       creation_error_message: nil
     )}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket |> assign(creation_error_message: nil)}
  end

  def handle_event("create", %{"create_stack" => %{"name" => name}}, socket) do
    socket =
      case Simulation.create_stack(socket.assigns.blueprint, name) do
        {:ok, %{stack: new_stack}} ->
          send_update(
            SimulationEditorComponent,
            id: "simulation_editor",
            action: :set_selection,
            selected_type: :stack,
            selected_id: new_stack.id
          )

          socket

        {:error, :case, _changeset, _} ->
          socket
          |> assign(
            creation_error_message:
              "invalid name: use only digits, letters, '-' or '_' and start with a letter."
          )
      end

    {:noreply, socket}
  end
end
