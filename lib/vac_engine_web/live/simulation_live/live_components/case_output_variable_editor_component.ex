defmodule VacEngineWeb.SimulationLive.CaseOutputVariableEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.SimulationHelpers
  import VacEngineWeb.SimulationLive.InputComponent
  import VacEngineWeb.IconComponent




  def update(assigns, socket) do
    expected =
      Map.get(assigns.case, :expect, %{})
      |> get_value(assigns.variable.path)

    forbidden =
      Map.get(assigns.case, :forbid, %{})
      |> variable_forbidden?(assigns.variable.path)

    actual =
      Map.get(assigns.case, :actual, %{})
      |> get_value(assigns.variable.path)

    mismatch=check_mismatch?({expected, forbidden, actual})


    socket = socket
             |> assign(assigns)
             |> assign(
                  expected: expected,
                  forbidden: forbidden,
                  actual: actual,
                  mismatch: mismatch
                )

    {:ok, socket}
  end
end
