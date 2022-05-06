defmodule VacEngineWeb.SimulationLive.StackInputComponent do
  @moduledoc false

  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias VacEngineWeb.SimulationLive.StackInputVariableComponent

  def mount(socket) do
    socket
    |> assign(filter: "template")
    |> ok()
  end

  def update(assigns, socket) do
    %{runnable_case: runnable_case} = assigns
    %{filter: previous_filter} = socket.assigns

    filter =
      if Enum.empty?(runnable_case.input_entries) do
        "all"
      else
        previous_filter
      end

    socket
    |> assign(assigns)
    |> assign(filter: filter)
    |> ok()
  end

  def handle_event("set_filter", %{"filter" => new_filter}, socket) do
    socket
    |> assign(filter: new_filter)
    |> noreply()
  end
end
