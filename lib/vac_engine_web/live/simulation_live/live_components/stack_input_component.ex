defmodule VacEngineWeb.SimulationLive.StackInputComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.SimulationLive.StackInputVariableComponent

  def mount(socket) do
    socket = socket |> assign(filter: "template")
    {:ok, socket}
  end

  def update(assigns, socket) do
    %{runnable_case: runnable_case} = assigns
    %{filter: previous_filter} = socket.assigns

    filter =
      if length(runnable_case.input_entries) == 0 do
        "all"
      else
        previous_filter
      end

    socket =
      socket
      |> assign(assigns)
      |> assign(filter: filter)

    {:ok, socket}
  end

  def handle_event("set_filter", %{"filter" => new_filter}, socket) do
    socket = socket |> assign(filter: new_filter)

    {:noreply, socket}
  end
end
