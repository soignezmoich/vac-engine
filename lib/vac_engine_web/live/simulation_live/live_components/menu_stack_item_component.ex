defmodule VacEngineWeb.SimulationLive.MenuStackItemComponent do
  use VacEngineWeb, :live_component

  import VacEngineWeb.IconComponent

  alias VacEngineWeb.SimulationLive.SimulationEditorComponent

  @impl true
  def update(
        %{
          id: id,
          stack_id: stack_id,
          stack_name: stack_name,
          selected: selected
        },
        socket
      ) do
    {:ok,
     socket
     |> assign(
       id: id,
       stack_id: stack_id,
       stack_name: stack_name,
       selected: selected,
       has_mismatch: false
     )}
  end

  @impl true
  def handle_event("select_item", params, socket) do
    send_update(SimulationEditorComponent,
      id: "simulation_editor",
      action: :set_selection,
      selected_type: :stack,
      selected_id: socket.assigns.stack_id
    )

    {:noreply, socket}
  end
end
