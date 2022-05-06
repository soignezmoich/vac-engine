defmodule VacEngineWeb.SimulationLive.MenuConfigComponent do
  @moduledoc false

  use VacEngineWeb, :live_component

  import VacEngineWeb.IconComponent

  alias VacEngineWeb.SimulationLive.SimulationEditorComponent

  def handle_event("select_config", _params, socket) do
    send_update(SimulationEditorComponent,
      id: "simulation_editor",
      action: :set_selection,
      selected_type: :config,
      selected_id: nil
    )

    {:noreply, socket}
  end
end
