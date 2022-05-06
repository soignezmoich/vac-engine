defmodule VacEngineWeb.SimulationLive.TemplateInputComponent do
  @moduledoc false

  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias VacEngineWeb.SimulationLive.TemplateInputVariableComponent

  def mount(socket) do
    socket
    |> assign(filter: "all")
    |> ok()
  end

  def handle_event("set_filter", %{"filter" => new_filter}, socket) do
    socket
    |> assign(filter: new_filter)
    |> noreply()
  end
end
