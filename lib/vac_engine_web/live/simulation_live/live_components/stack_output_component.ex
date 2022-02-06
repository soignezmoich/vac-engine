defmodule VacEngineWeb.SimulationLive.StackOutputComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.SimulationLive.StackOutputVariableComponent
  alias VacEngineWeb.SimulationLive.ToggleEntryComponent

  def mount(socket) do
    socket = socket |> assign(filter: "case")

    {:ok, socket}
  end

  def update(
        %{
          output_variables: output_variables,
          runnable_case: runnable_case,
          results: results,
          stack: stack
        },
        socket
      ) do
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

    # output_variables
    # |> Enum.map(fn ov -> {ov.name, Map.get(ov, :actual)} end)

    socket =
      socket
      |> assign(
        output_variables: output_variables,
        runnable_case: runnable_case,
        stack: stack
      )

    {:ok, socket}
  end

  def handle_event("set_filter", %{"filter" => new_filter}, socket) do
    socket = socket |> assign(filter: new_filter)

    {:noreply, socket}
  end

  defp get_outcome(%{absent_while_expected?: true}), do: :failure
  defp get_outcome(%{present_while_forbidden?: true}), do: :failure
  defp get_outcome(%{match?: true}), do: :success
  defp get_outcome(%{match?: false}), do: :failure
  defp get_outcome(%{forbid?: true}), do: :success
  defp get_outcome(_result), do: :not_tested
end
