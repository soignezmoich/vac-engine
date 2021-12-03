defmodule VacEngineWeb.EditorLive.VariableInspectorComponent do
  use VacEngineWeb, :live_component
  import VacEngineWeb.ToggleComponent

  alias VacEngine.Processor.Variable
  import VacEngine.VariableHelpers

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       input_containers: [],
       intermediate_containers: [],
       output_containers: [],
       variable: nil
     )}
  end

  @impl true
  def update(%{variable: nil}, socket) do
    {:ok, assign(socket, variable: nil)}
  end

  @impl true
  def update(%{variables: vars, variable: variable}, socket) do
    containers =
      case {Variable.input?(variable), Variable.output?(variable)} do
        {true, _} -> get_containers(vars, "input")
        {false, false} -> get_containers(vars, "intermediate")
        {_, true} -> get_containers(vars, "output")
      end

    {:ok,
     assign(socket,
       variable_container_path: variable.path |> Enum.drop(-1),
       containers: containers,
       variable: variable
     )}
  end
end
