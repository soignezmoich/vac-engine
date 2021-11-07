defmodule VacEngineWeb.Editor.DeductionSetEditorComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.Editor.DeductionListComponent, as: DeductionList

  def update(assigns, socket) do
    {:ok, assign(socket, deductions: assigns.deductions)}
  end
end
