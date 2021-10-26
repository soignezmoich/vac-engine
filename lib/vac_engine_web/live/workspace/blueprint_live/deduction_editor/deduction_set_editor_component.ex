defmodule VacEngineWeb.Editor.DeductionSetEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngineWeb.Editor.DeductionActionGroupComponent
  import VacEngineWeb.Editor.DeductionComponent
  import VacEngineWeb.Editor.FormActionGroupComponent
  import VacEngineWeb.Editor.ExpressionEditorComponent

  def update(assigns, socket) do
    deductions_with_path =
      assigns.deductions
      |> Enum.with_index()
      |> Enum.map(fn {deduction, index} ->
        {[index | assigns.path], deduction}
      end)

    {:ok,
     assign(socket,
       deductions_with_path: deductions_with_path,
       selection_path: nil
     )}
  end
end
