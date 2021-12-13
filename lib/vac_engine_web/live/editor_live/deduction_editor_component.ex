defmodule VacEngineWeb.EditorLive.DeductionEditorComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.EditorLive.DeductionListComponent, as: DeductionList
  alias VacEngineWeb.EditorLive.DeductionInspectorComponent

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
