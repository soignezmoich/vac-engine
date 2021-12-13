defmodule VacEngine.EditorLive.CellComponentTest do
  use ExUnit.Case

  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Condition
  alias VacEngineWeb.EditorLive.DeductionCellComponent, as: Cell

  # Type property

  @is_condition true
  @cell %Condition{expression: %{ast: {:var, [], [["var", "name"]]}}}
  @path [:deduction, 3, :branch, 2]

  @expected_type "variable"

  test "'build_renderable' should make variable type" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell %Condition{expression: %{ast: {:gt, [], []}}}

  @expected_type "operator"

  test "'build_renderable' should make operator type" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell %Condition{expression: %{ast: true}}

  @expected_type "const"

  test "'build_renderable' should make const type when ast is boolean" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell %Condition{expression: %{ast: "bla"}}

  @expected_type "const"

  test "'build_renderable' should make const type when ast is string" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell %Condition{expression: %{ast: 121}}

  @expected_type "const"

  test "'build_renderable' should make const type when ast is number" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell nil

  @expected_type "nil"

  test "'build_renderable' should make nil type" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  # Value property

  @is_condition true
  @cell %Condition{expression: %{ast: {:var, [], [["var", "name"]]}}}
  @path [:deduction, 3, :branch, 2]

  @expected_value "@var.name"

  test "'build_renderable' should make variable value" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell %Condition{expression: %{ast: {:gt, [], []}}}

  @expected_value :gt

  test "'build_renderable' should make operator value" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell %Condition{expression: %{ast: true}}

  @expected_value "true"

  test "'build_renderable' should make const value when ast is boolean" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell %Condition{expression: %{ast: "bla"}}

  @expected_value "\"bla\""

  test "'build_renderable' should make const value when ast is string" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell %Condition{expression: %{ast: 121}}

  @expected_value "121"

  test "'build_renderable' should make const value when ast is number" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell nil

  @expected_value "-"

  test "'build_renderable' should make nil value" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  # Args property

  @cell %Condition{expression: %{ast: {:gt, [], [{:var, [], [["bla"]]}, 10]}}}

  # @expected_value 10

  test "'build_renderable' should make args when cell is condition" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:args) == ["10"]
  end

  @is_condition false
  @cell %Assignment{expression: %{ast: {:gt, [], [{:var, [], [["bla"]]}, 10]}}}

  # @expected_value 10

  test "'build_renderable' should make args when cell is assignment" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:args) == ["@bla", "10"]
  end

  # Cell style property

  @path [:deduction, 0, :branch, 3, :condition, 5]

  test "'build_renderable' should set more opacity when row is odd" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable
           |> Map.get(:cell_style)
           |> String.contains?("bg-opacity-50")
  end

  @path [:deduction, 0, :branch, 4, :condition, 5]

  test "'build_renderable' should set less opacity when row is even" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable
           |> Map.get(:cell_style)
           |> String.contains?("bg-opacity-30")
  end

  # Dot path property

  @is_condition true
  @path [:deduction, 3, :branch, 2, :condition, 1]

  @expected_dot_path "deduction.3.branch.2.condition.1"

  test "'build_renderable' should make proper condition dot path" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:dot_path) == @expected_dot_path
  end

  @is_condition false
  @path [:deduction, 3, :branch, 2, :assignment, 1]

  @expected_dot_path "deduction.3.branch.2.assignment.1"

  test "'build_renderable' should make proper assignment dot path" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:dot_path) == @expected_dot_path
  end

  # Description property

  @is_condition true
  @cell %Condition{
    expression: %{ast: {:var, [], [["var", "name"]]}},
    description: "blabla"
  }
  @path [:deduction, 3, :branch, 2, :assignment, 1]

  @expected_description ""

  test "'build_renderable' should make no description for conditions" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:description) == @expected_description
  end

  @is_condition false
  @cell %Assignment{
    expression: %{ast: {:var, [], [["var", "name"]]}},
    description: "blabla"
  }
  @path [:deduction, 3, :branch, 2]

  @expected_description "(blabla)"

  test "'build_renderable' should make description for assignments" do
    renderable =
      Cell.build_renderable(
        @is_condition,
        @cell,
        @path,
        nil
      )

    assert renderable |> Map.get(:description) == @expected_description
  end

  # selected property (not tested, currently always false)
end
