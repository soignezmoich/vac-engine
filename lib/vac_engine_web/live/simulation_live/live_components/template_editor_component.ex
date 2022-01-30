defmodule VacEngineWeb.SimulationLive.TemplateEditorComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.TemplateInputComponent

  def update(%{id: id, blueprint: blueprint, template_id: template_id}, socket) do
    socket =
      socket
      |> assign(
        id: id,
        blueprint: blueprint,
        template: Simulation.get_template(template_id)
      )

    {:ok, socket}
  end
end
