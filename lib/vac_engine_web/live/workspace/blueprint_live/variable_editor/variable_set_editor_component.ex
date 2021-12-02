defmodule VacEngineWeb.Editor.VariableSetEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.VariableHelpers
  import VacEngineWeb.Editor.VariableActionGroupComponent
  import VacEngineWeb.Editor.VariableInspectorComponent

  alias VacEngineWeb.Editor.VariableListComponent, as: VariableList

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      assign(socket,
        variables: assigns.variables,
        selection_path: nil,
        selected_variable: nil,
        # maybe compute them here
        map_variables: nil,
        input_containers: [],
        intermediate_containers: [],
        output_containers: []
      )
    }
  end

  @impl true
  def handle_event("select_variable", params, socket) do
    selection_path =
      case params do
        %{"path" => dot_path} when is_binary(dot_path) ->
          dot_path |> String.split(".")

        _ ->
          nil
      end

    # TODO sanitize path parameter

    selected_variable =
      socket.assigns.variables
      |> get_variable_at(selection_path)

    input_containers =
      socket.assigns.variables
      |> get_containers("input")

    intermediate_containers =
      socket.assigns.variables
      |> get_containers("intermediate")

    output_containers =
      socket.assigns.variables
      |> get_containers("output")

    {:noreply,
     assign(socket, %{
       selection_path: selection_path,
       selected_variable: selected_variable,
       input_containers: input_containers,
       intermediate_containers: intermediate_containers,
       output_containers: output_containers
     })}
  end

  # defp get_mapping_key(variable) do

  #   {input, output} = {input?(variable), output?(variable)}

  # end

  # defp get_containers(variable) do
  #   %{
  #     input:
  #     intermediate:
  #     output:
  #   }
  # end
end
