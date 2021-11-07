defmodule VacEngineWeb.Editor.VariableSetEditorComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.Editor.VariableListComponent, as: VariableList

  def update(assigns, socket) do
    {:ok, assign(socket, variables: assigns.variables)}
  end
end
