defmodule VacEngineWeb.Editor.DeductionSetEditorComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.Editor.DeductionListComponent, as: DeductionList

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket,
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
