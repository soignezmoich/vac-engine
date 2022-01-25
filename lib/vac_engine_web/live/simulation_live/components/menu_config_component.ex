defmodule VacEngineWeb.SimulationLive.MenuConfigComponent do
  use Phoenix.Component

  import VacEngineWeb.IconComponent

  def render(assigns) do
    ~H"""
      <div class="w-full bg-white filter drop-shadow-lg p-3 cursor-default">
        <div class="font-bold mb-2 border-b border-black">
          Simulation
        </div>
        <div class="link flex"
          phx-value-section={"config"}
          phx-click={"menu_select"}
          phx-target={"#simulation_editor"}
        >
          <div class="inline-block">
            <.icon name="hero/cog" width="1.25rem" />
          </div>
          Configuration
        </div>
      </div>
    """
  end
end
