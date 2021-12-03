defmodule VacEngineWeb.EditorLive.DeductionEditorComponent do
  use VacEngineWeb, :live_component
  import VacEngineWeb.EditorLive.DeductionActionGroupComponent
  import VacEngineWeb.EditorLive.ExpressionEditorComponent

  alias VacEngineWeb.EditorLive.DeductionListComponent, as: DeductionList

  @impl true
  def update(assigns, socket) do
    {:ok,
     assign(socket,
       deductions: assigns.deductions,
       selection_path: nil
     )}
  end

  @impl true
  def handle_event("select_cell", params, socket) do
    selection_path =
      case params do
        %{"path" => dot_path} when is_binary(dot_path) -> dot_path
        _ -> nil
      end

    {:noreply, assign(socket, %{selection_path: selection_path})}
  end
end
