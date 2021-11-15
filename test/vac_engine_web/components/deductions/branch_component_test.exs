defmodule VacEngine.Editor.BranchComponentTest do
  use ExUnit.Case

  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Condition
  alias VacEngineWeb.Editor.BranchComponent

  # Has cond cells? property

  @branch %Branch{conditions: [], assignments: []}
  @cond_columns []
  @assign_columns []
  @parent_path ["deductions", 2]
  @index 5
  @expected_has_cond_cells? false

  test "'build_renderable' should make has_cond_cells? false if no condition column" do
    renderable =
      BranchComponent.build_renderable(
        @branch,
        @cond_columns,
        @assign_columns,
        @parent_path,
        @index
      )

    assert renderable |> Map.get(:has_cond_cells?) == @expected_has_cond_cells?
  end

  @branch %Branch{conditions: [], assignments: []}
  @cond_columns [%Column{type: :condition}]
  @assign_columns []
  @parent_path ["deductions", 2]
  @index 5
  @expected_has_cond_cells? true

  test "'build_renderable' should make has_cond_cells? true if some condition column" do
    renderable =
      BranchComponent.build_renderable(
        @branch,
        @cond_columns,
        @assign_columns,
        @parent_path,
        @index
      )

    assert renderable |> Map.get(:has_cond_cells?) == @expected_has_cond_cells?
  end

  # Cond cells property

  @condition %Condition{column_id: 0}
  @condition2 %Condition{column_id: 1}
  @branch %Branch{
    conditions: [@condition, @condition2],
    assignments: []
  }
  @cond_columns [
    %Column{type: :condition, id: 0},
    %Column{type: :condition, id: 1}
  ]
  @assign_columns []
  @parent_path ["deductions", 2]
  @index 5
  @expected_cond_cells [@condition, @condition2]

  test "'build_renderable' should make cond_cells if some condition column" do
    renderable =
      BranchComponent.build_renderable(
        @branch,
        @cond_columns,
        @assign_columns,
        @parent_path,
        @index
      )

    assert renderable |> Map.get(:cond_cells) == @expected_cond_cells
  end

  # assignment cells property

  @assignment %Assignment{column_id: 3}
  @assignment2 %Assignment{column_id: 4}
  @branch %Branch{
    conditions: [],
    assignments: [@assignment, @assignment2]
  }
  @cond_columns []
  @assign_columns [
    %Column{type: :assignment, id: 3},
    %Column{type: :assignment, id: 4}
  ]
  @parent_path ["deductions", 2]
  @index 5
  @expected_assign_cells [@assignment, @assignment2]

  test "'build_renderable' should make assign_cells" do
    renderable =
      BranchComponent.build_renderable(
        @branch,
        @cond_columns,
        @assign_columns,
        @parent_path,
        @index
      )

    assert renderable |> Map.get(:assign_cells) == @expected_assign_cells
  end

  # Path property
  @branch %Branch{conditions: [], assignments: []}
  @cond_columns []
  @assign_columns []
  @parent_path ["deductions", 2]
  @index 5
  @expected_path ["deductions", 2, "branches", 5]

  test "'build_renderable' should make correct path" do
    renderable =
      BranchComponent.build_renderable(
        @branch,
        @cond_columns,
        @assign_columns,
        @parent_path,
        @index
      )

    assert renderable |> Map.get(:path) == @expected_path
  end
end
