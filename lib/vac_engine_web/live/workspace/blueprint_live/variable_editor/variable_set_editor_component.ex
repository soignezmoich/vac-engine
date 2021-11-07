defmodule VacEngineWeb.Editor.VariableSetEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngineWeb.Editor.VariableListComponent

  def update(assigns, socket) do
    {:ok, assign(socket, variables: assigns.variables)}
  end
end
