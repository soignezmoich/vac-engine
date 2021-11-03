defmodule VacEngine.Editor.Renderables.BranchRenderableTest do
  use ExUnit.Case

  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  alias VacEngineWeb.Editor.BranchRenderable
  alias VacEngineWeb.Editor.CellRenderable

  @branch %Branch{
    conditions: [],
    assignments: []
  }

  @even_row true
  @cond_cols []
  @assign_cols []
  @path [0, "branches", 0, "conditions", 0]
  @selected_path nil

  @renderable %{
    condition_cells: [],
    assignment_cells: []
  }

  test "'build' should build a valid renderable from an empty deduction branch" do
    assert BranchRenderable.build(
             @branch,
             @cond_cols,
             @assign_cols,
             @path,
             @selected_path,
             @even_row
           ) == @renderable
  end

  @empty_cond_renderable CellRenderable.build(
                           nil,
                           :condition,
                           [0, "branches", 0, "conditions", 0],
                           nil,
                           true
                         )

  @cond_cols [%Column{id: 32}]
  @assign_cols []

  @renderable %{
    condition_cells: [@empty_cond_renderable],
    assignment_cells: []
  }

  test "'build' should build a valid renderable from a one condition column, no condition branch" do
    assert BranchRenderable.build(
             @branch,
             @cond_cols,
             @assign_cols,
             @path,
             @selected_path,
             @even_row
           ) == @renderable
  end

  @empty_assign_renderable CellRenderable.build(
                             nil,
                             :assignment,
                             [0, "branches", 0, "assignments", 0],
                             nil,
                             true
                           )

  @cond_cols []
  @assign_cols [%Column{id: 21}]

  @renderable %{
    condition_cells: [],
    assignment_cells: [@empty_cond_renderable]
  }

  test "'build' should build a valid renderable from a one assignment column, no assignment branch" do
    assert BranchRenderable.build(
             @branch,
             @cond_cols,
             @assign_cols,
             @path,
             @selected_path,
             @even_row
           ) == @renderable
  end

  @empty_assign_renderable CellRenderable.build(
                             nil,
                             :assignment,
                             [0, "branches", 0, "assignments", 0],
                             nil,
                             true
                           )

  @cond_cols []
  @assign_cols [%Column{id: 21}]

  @renderable %{
    condition_cells: [],
    assignment_cells: [@empty_cond_renderable]
  }

  test "'build' should build a valid renderable from a fully populated branch (1 conds, 1 assigns)" do
    assert BranchRenderable.build(
             @branch,
             @cond_cols,
             @assign_cols,
             @path,
             @selected_path,
             @even_row
           ) == @renderable
  end
end
