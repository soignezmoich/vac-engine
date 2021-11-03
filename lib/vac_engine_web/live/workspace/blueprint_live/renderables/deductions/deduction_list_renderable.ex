defmodule VacEngineWeb.Editor.DeductionListRenderable do
  def build(deductions) do
    deductions
    |> Enum.with_index()
    |> Enum.map(fn {deduction, index} ->
      {[index, "deductions"], deduction}
    end)
  end
end
