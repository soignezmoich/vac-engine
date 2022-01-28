defmodule VacEngineWeb.SimulationLive.MenuTemplateItemComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.SimulationLive.SimulationEditorComponent

  def handle_event("select_item", params, socket) do
    send_update(SimulationEditorComponent,
      id: "simulation_editor",
      action: :set_selection,
      selected_type: :template,
      selected_id: socket.assigns.template_id
    )

    {:noreply, socket}
  end
end
