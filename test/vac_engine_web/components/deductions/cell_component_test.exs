defmodule VacEngine.EditorLive.CellComponentTest do
  use ExUnit.Case

  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  alias VacEngineWeb.EditorLive.DeductionCellComponent, as: Cell

  # Type property

  @column %Column{type: :condition, id: 0}
  @cell %Condition{expression: %{ast: {:var, [], [["var", "name"]]}}}
  @branch %Branch{conditions: [@cell], assignments: []}

  @expected_type :variable

  test "'build_renderable' should make variable type" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell %Condition{expression: %{ast: {:gt, [], []}}}

  @expected_type :function

  test "'build_renderable' should make operator type" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell %Condition{expression: %{ast: true}}

  @expected_type :constant

  test "'build_renderable' should make const type when ast is boolean" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell %Condition{expression: %{ast: "bla"}}

  @expected_type :constant

  test "'build_renderable' should make const type when ast is string" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell %Condition{expression: %{ast: 121}}

  @expected_type :constant

  test "'build_renderable' should make const type when ast is number" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  @cell nil

  @expected_type nil

  test "'build_renderable' should make nil type" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  # Value property

  @cell %Condition{expression: %{ast: {:var, [], [["var", "name"]]}}}

  @expected_value "@var.name"

  test "'build_renderable' should make variable value" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell %Condition{expression: %{ast: {:gt, [], []}}}

  @expected_value "gt()"

  test "'build_renderable' should make operator value" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell %Condition{expression: %{ast: true}}

  @expected_value "true"

  test "'build_renderable' should make const value when ast is boolean" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell %Condition{expression: %{ast: "bla"}}

  @expected_value "bla"

  test "'build_renderable' should make const value when ast is string" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell %Condition{expression: %{ast: 121}}

  @expected_value "121"

  test "'build_renderable' should make const value when ast is number" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  @cell nil

  @expected_value "-"

  test "'build_renderable' should make nil value" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:value) == @expected_value
  end

  # Cell style property

  test "'build_renderable' should set more opacity when row is odd" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable
           |> Map.get(:cell_style)
           |> String.contains?("bg-opacity-50")
  end

  @branch %Branch{conditions: [], assignments: [@cell], position: 0}

  test "'build_renderable' should set less opacity when row is even" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable
           |> Map.get(:cell_style)
           |> String.contains?("bg-opacity-30")
  end

  # Description property

  @cell %Condition{
    expression: %{ast: {:var, [], [["var", "name"]]}},
    description: "blabla"
  }
  @branch %Branch{conditions: [@cell], assignments: [], position: 0}
  @column %Column{type: :condition, id: 0}

  @expected_description ""

  test "'build_renderable' should make no description for conditions" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:description) == @expected_description
  end

  @cell %Assignment{
    expression: %{ast: {:var, [], [["var", "name"]]}},
    description: "blabla"
  }
  @column %Column{type: :assignment, id: 0}
  @branch %Branch{conditions: [], assignments: [@cell], position: 1}

  @expected_description "(blabla)"

  test "'build_renderable' should make description for assignments" do
    renderable =
      Cell.build_renderable(
        @branch,
        @column,
        @cell,
        nil
      )

    assert renderable |> Map.get(:description) == @expected_description
  end

  # selected property (not tested, currently always false)
end
