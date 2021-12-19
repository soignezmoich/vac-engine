defmodule VacEngine.EditorLive.DeductionComponentTest do
  use ExUnit.Case

  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Deduction
  alias VacEngineWeb.EditorLive.DeductionComponent

  # Branches property

  @deduction %Deduction{branches: [], columns: []}
  @expected_branches []
  @sel %{}

  test "'build_renderable' should build empty branches array if deduction has none" do
    renderable = DeductionComponent.build_renderable(@deduction, @sel)

    assert renderable |> Map.get(:branches) == @expected_branches
  end

  @deduction %Deduction{branches: [%Branch{}], columns: []}
  @expected_branches [%Branch{}]
  @sel %{}

  test "'build_renderable' should build branches array if deduction has some" do
    renderable = DeductionComponent.build_renderable(@deduction, @sel)

    assert renderable |> Map.get(:branches) == @expected_branches
  end

  # Cond/assign columns property

  @cond_column %Column{type: :condition, id: 1}
  @cond_column_2 %Column{type: :condition, id: 2}
  @assign_column %Column{type: :assignment, id: 3}
  @assign_column_2 %Column{type: :assignment, id: 4}
  @deduction %Deduction{
    branches: [],
    columns: [
      @cond_column,
      @cond_column_2,
      @assign_column,
      @assign_column_2
    ]
  }
  @expected_cond_columns [@cond_column, @cond_column_2]
  @expected_assign_columns [@assign_column, @assign_column_2]
  @sel %{}

  test "'build_renderable' should build proper cond and assign columns" do
    renderable = DeductionComponent.build_renderable(@deduction, @sel)

    assert renderable |> Map.get(:cond_columns) == @expected_cond_columns
    assert renderable |> Map.get(:assign_columns) == @expected_assign_columns
  end
end
