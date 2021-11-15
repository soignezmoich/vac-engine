defmodule VacEngine.Editor.CellComponentTest do
  use ExUnit.Case

  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Condition
  alias VacEngineWeb.Editor.CellComponent

  # Type property

  @is_condition true
  @cell %Condition{expression: %{ast: {:var, [], [["var", "name"]]}}}
  @parent_path ["deductions", 3, "branches", 2]
  @index 1
  @row_index 5

  @expected_type "variable"

  test "'build_renderable' should make variable type" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell %Condition{expression: %{ast: {:gt, [], []}}}

  @expected_type "operator"

  test "'build_renderable' should make operator type" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell %Condition{expression: %{ast: true}}

  @expected_type "const"

  test "'build_renderable' should make const type when ast is boolean" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell %Condition{expression: %{ast: "bla"}}

  @expected_type "const"

  test "'build_renderable' should make const type when ast is string" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell %Condition{expression: %{ast: 121}}

  @expected_type "const"

  test "'build_renderable' should make const type when ast is number" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell nil

  @expected_type "nil"

  test "'build_renderable' should make nil type" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  # Value property

  @is_condition true
  @cell %Condition{expression: %{ast: {:var, [], [["var", "name"]]}}}
  @parent_path ["deductions", 3, "branches", 2]
  @index 1
  @row_index 5

  @expected_value "@var.name"

  test "'build_renderable' should make variable value" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell %Condition{expression: %{ast: {:gt, [], []}}}

  @expected_value :gt

  test "'build_renderable' should make operator value" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell %Condition{expression: %{ast: true}}

  @expected_value "true"

  test "'build_renderable' should make const value when ast is boolean" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell %Condition{expression: %{ast: "bla"}}

  @expected_value "\"bla\""

  test "'build_renderable' should make const value when ast is string" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell %Condition{expression: %{ast: 121}}

  @expected_value "121"

  test "'build_renderable' should make const value when ast is number" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell nil

  @expected_value "-"

  test "'build_renderable' should make nil value" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  # Args property

  @cell %Condition{expression: %{ast: {:gt, [], [{:var, [], [["bla"]]}, 10]}}}

  # @expected_value 10

  test "'build_renderable' should make args when cell is condition" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:args) == ["10"]
  end

  @is_condition false
  @cell %Assignment{expression: %{ast: {:gt, [], [{:var, [], [["bla"]]}, 10]}}}

  # @expected_value 10

  test "'build_renderable' should make args when cell is assignment" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:args) == ["@bla", "10"]
  end

  # Cell style property

  @row_index 3

  test "'build_renderable' should set more opacity when row is odd" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable
           |> Map.get(:cell_style)
           |> String.contains?("bg-opacity-50")
  end

  @row_index 2

  test "'build_renderable' should set less opacity when row is even" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable
           |> Map.get(:cell_style)
           |> String.contains?("bg-opacity-30")
  end

  # Dot path property

  @is_condition true
  @parent_path ["deductions", 3, "branches", 2]
  @index 1

  @expected_dot_path "deductions.3.branches.2.conditions.1"

  test "'build_renderable' should make proper condition dot path" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:dot_path) == @expected_dot_path
  end

  @is_condition false
  @parent_path ["deductions", 3, "branches", 2]
  @index 1

  @expected_dot_path "deductions.3.branches.2.assignments.1"

  test "'build_renderable' should make proper assignment dot path" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:dot_path) == @expected_dot_path
  end

  # Description property

  @is_condition true
  @cell %Condition{
    expression: %{ast: {:var, [], [["var", "name"]]}},
    description: "blabla"
  }
  @parent_path ["deductions", 3, "branches", 2]
  @index 1

  @expected_description ""

  test "'build_renderable' should make no description for conditions" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:description) == @expected_description
  end

  @is_condition false
  @cell %Assignment{
    expression: %{ast: {:var, [], [["var", "name"]]}},
    description: "blabla"
  }
  @parent_path ["deductions", 3, "branches", 2]
  @index 1

  @expected_description "(blabla)"

  test "'build_renderable' should make description for assignments" do
    renderable =
      CellComponent.build_renderable(
        @is_condition,
        @cell,
        @parent_path,
        @index,
        @row_index
      )

    assert renderable |> Map.get(:description) == @expected_description
  end

  # selected property (not tested, currently always false)
end
