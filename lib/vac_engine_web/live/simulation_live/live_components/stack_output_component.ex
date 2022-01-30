defmodule VacEngineWeb.SimulationLive.StackOutputComponent do
  use VacEngineWeb, :live_component

  import VacEngine.VariableHelpers

  alias VacEngineWeb.SimulationLive.StackOutputVariableComponent

  def mount(socket) do
    {:ok,
     socket
     |> assign(filter: "case")}
  end

  def handle_event("set_filter", %{"filter" => new_filter}, socket) do
    {:noreply,
     socket
     |> assign(filter: new_filter)}
  end
end
