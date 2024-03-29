defmodule VacEngineWeb.SimulationLive.StackOutputComponent do
  @moduledoc false

  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias VacEngineWeb.SimulationLive.StackOutputVariableComponent
  alias VacEngineWeb.SimulationLive.ExpectRunErrorComponent

  def mount(socket) do
    socket
    |> assign(filter: "case")
    |> ok()
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
            |> Map.merge(Map.take(result, [:actual, :present_while_forbidden]))
            |> Map.put(:outcome, get_outcome(result))
        end
      end)

    filter =
      if Enum.empty?(runnable_case.output_entries) do
        "all"
      else
        previous_filter
      end

    socket
    |> assign(
      causes_error: causes_error,
      output_variables: output_variables,
      runnable_case: runnable_case,
      stack: stack,
      filter: filter
    )
    |> ok()
  end

  def handle_event("set_filter", %{"filter" => new_filter}, socket) do
    socket
    |> assign(filter: new_filter)
    |> noreply()
  end

  defp get_outcome(%{absent_while_expected: true}), do: :failure
  defp get_outcome(%{present_while_forbidden: true}), do: :failure
  defp get_outcome(%{match: true}), do: :success
  defp get_outcome(%{match: false}), do: :failure
  defp get_outcome(%{forbid: true}), do: :success
  defp get_outcome(_result), do: :not_tested
end
