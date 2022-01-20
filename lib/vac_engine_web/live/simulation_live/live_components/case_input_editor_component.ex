defmodule VacEngineWeb.SimulationLive.CaseInputEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.VariableHelpers

  alias VacEngineWeb.SimulationLive.CaseInputVariableEditorComponent,
    as: InputVariableEditor

  def mount(socket) do
    {:ok,
     socket
     |> assign(filter: "template")}
  end

  def handle_event("set_filter", %{"filter" => new_filter}, socket) do
    IO.inspect(new_filter)

    {:noreply,
     socket
     |> assign(filter: new_filter)}
  end
end
