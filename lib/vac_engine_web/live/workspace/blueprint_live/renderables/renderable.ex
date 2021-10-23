defmodule VacEngineWeb.Editor.BlueprintRenderables do
  alias VacEngine.Processor.Blueprint
  alias VacEngineWeb.Editor.DeductionRenderables
  alias VacEngineWeb.Editor.VariableRenderables

  def build(%Blueprint{} = blueprint) do
    result = %{
      deductions: DeductionRenderables.build(blueprint.deductions),
      variables:
        VariableRenderables.build(blueprint.variables, "input.birthdate")
    }

    IO.inspect(result)
  end
end
