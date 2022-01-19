defmodule VacEngineWeb.SimulationLive.ConfigEditorComponent do
  use Phoenix.Component

  import VacEngineWeb.SimulationLive.InputComponent

  def render(assigns) do
    ~H"""
      <div class="m-3">
        <div class="text-2xl font-bold mb-4">Configuration</div>
        <div class="h-4" />
        <div>Day of simulation</div>
        <.date_input value="2021-11-15" />
      </div>
    """
  end

end
