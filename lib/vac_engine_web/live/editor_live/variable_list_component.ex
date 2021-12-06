defmodule VacEngineWeb.EditorLive.VariableListComponent do
  use VacEngineWeb, :live_component

  import VacEngine.VariableHelpers
  import Elixir.Integer, only: [is_even: 1]
  alias VacEngineWeb.EditorLive.VariableComponent

  @impl true
  def mount(socket) do
    {:ok, assign(socket, selected_variable: nil)}
  end

  @impl true
  def update(%{action: {:select_variable, var}}, socket) do
    {:ok, assign(socket, selected_variable: var)}
  end

  @impl true
  def update(
        %{blueprint: blueprint, selected_variable: selected_variable},
        socket
      ) do
    {
      :ok,
      socket
      |> assign(build_renderable(blueprint.variables))
      |> assign(selected_variable: selected_variable)
    }
  end

  def build_renderable(variables) do
    input = variables |> flatten_variables("input")
    output = variables |> flatten_variables("output")
    intermediate = variables |> flatten_variables("intermediate")

    %{
      input_variables: input,
      output_variables: output,
      intermediate_variables: intermediate
    }
  end
end
