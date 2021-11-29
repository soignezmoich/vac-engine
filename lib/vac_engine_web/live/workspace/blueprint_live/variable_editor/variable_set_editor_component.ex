defmodule VacEngineWeb.Editor.VariableSetEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngineWeb.Editor.VariableActionGroupComponent
  import VacEngineWeb.Editor.VariableInspectorComponent

  alias VacEngineWeb.Editor.VariableListComponent, as: VariableList

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      assign(socket,
        variables: assigns.variables,
        selection_path: ["variables", "input", "extremely_vulnerable"]
      )
    }
  end

  @impl true
  def handle_event("select_variable", params, socket) do
    selection_path =
      case params do
        %{"path" => dot_path} when is_binary(dot_path) -> dot_path
        _ -> nil
      end

    {:noreply, assign(socket, %{selection_path: selection_path})}
  end
end
