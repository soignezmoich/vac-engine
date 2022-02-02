defmodule VacEngineWeb.SimulationLive.TemplateInputComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.SimulationLive.TemplateInputVariableComponent

  def mount(socket) do
    socket = socket |> assign(filter: "template")
    {:ok, socket}
  end

  def handle_event("set_filter", %{"filter" => new_filter}, socket) do
    socket = socket |> assign(filter: new_filter)

    {:noreply, socket}
  end
end
