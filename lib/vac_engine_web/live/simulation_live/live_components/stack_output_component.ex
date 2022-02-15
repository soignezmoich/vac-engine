defmodule VacEngineWeb.SimulationLive.StackOutputComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.SimulationLive.StackOutputVariableComponent
  alias VacEngineWeb.SimulationLive.ExpectRunErrorComponent

  def mount(socket) do
    socket = socket |> assign(filter: "case")

    {:ok, socket}
  end

  def update(
        %{
          causes_error: causes_error,
          output_variables: output_variables,
          results: results,
          runnable_case: runnable_case,
          stack: stack
        },
        socket
      ) do
    %{filter: previous_filter} = socket.assigns

    output_variables =
      output_variables
      |> Enum.map(fn variable ->
        Map.fetch(results, variable.path)
        |> case do
          :error ->
            variable

          {:ok, result} ->
            variable
            |> Map.merge(
              Map.take(result, [:outcome, :actual, :present_while_forbidden])
            )
        end
      end)

    filter =
      if length(runnable_case.output_entries) == 0 do
        "all"
      else
        previous_filter
      end

    socket =
      socket
      |> assign(
        causes_error: causes_error,
        output_variables: output_variables,
        runnable_case: runnable_case,
        stack: stack,
        filter: filter
      )

    {:ok, socket}
  end

  def handle_event("set_filter", %{"filter" => new_filter}, socket) do
    socket = socket |> assign(filter: new_filter)

    {:noreply, socket}
  end
end
