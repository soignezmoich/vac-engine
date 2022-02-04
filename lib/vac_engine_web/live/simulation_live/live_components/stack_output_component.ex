defmodule VacEngineWeb.SimulationLive.StackOutputComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.SimulationLive.StackOutputVariableComponent

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
      if results do
        results_by_variable_id =
          results
          |> Enum.map(fn {_path_list, result_table} ->
            {result_table.variable_id,
             result_table
             |> Enum.filter(fn {key, _value} -> key in [:output, :match?] end)}
          end)
          |> Map.new()

        output_variables
        |> Enum.map(fn variable ->
          result = results_by_variable_id[variable.id]

          variable
          |> Map.put(:actual, Keyword.get(result, :output))
          |> Map.put(:match?, Keyword.get(result, :match?))
        end)
      else
        output_variables
      end

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
end
