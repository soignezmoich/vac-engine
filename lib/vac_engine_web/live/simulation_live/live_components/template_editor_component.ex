defmodule VacEngineWeb.SimulationLive.TemplateEditorComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.TemplateInputComponent

  def update(%{action: {:refresh, _token}}, socket) do
    socket =
      socket
      |> assign(template: Simulation.get_template(socket.assigns.template.id))

    {:ok, socket}
  end

  def update(%{id: id, template_id: template_id, input_variables: input_variables}, socket) do
    socket =
      socket
      |> assign(
        id: id,
        input_variables: input_variables,
        template: Simulation.get_template(template_id)
      )

    {:ok, socket}
  end
end
