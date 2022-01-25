defmodule VacEngineWeb.SimulationLive.CaseOutputEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.VariableHelpers

  alias VacEngineWeb.SimulationLive.CaseOutputVariableEditorComponent,
    as: OutputVariableEditor

  def mount(socket) do
    {:ok,
     socket
     |> assign(filter: "case")}
  end

  def handle_event("set_filter", %{"filter" => new_filter}, socket) do
    IO.inspect(new_filter)

    {:noreply,
     socket
     |> assign(filter: new_filter)}
  end
end
