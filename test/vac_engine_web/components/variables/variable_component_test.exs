defmodule VacEngine.Editor.VariableComponentTest do
  use ExUnit.Case

  alias VacEngine.Processor.Variable
  alias VacEngineWeb.Editor.VariableComponent

  # Name property

  @variable %Variable{name: "age"}
  @path ["variables", "input", "age"]
  @expected_name "age"
  @even true
  @selection_path nil

  test "'build_renderable' should build proper name" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @path,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:name) == @expected_name
  end

  # Type property

  @variable %Variable{type: :integer}
  @path ["variables", "input", "age"]
  @expected_type :integer

  test "'build_renderable' should build proper type" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @path,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  # Required property

  @variable %Variable{mapping: nil}
  @path ["variables", "input", "age"]
  @expected_required ""

  test "'build_renderable' should not mark required if mapping==nil" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @path,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:required) == @expected_required
  end

  @variable %Variable{mapping: :none}
  @path ["variables", "input", "age"]
  @expected_required ""

  test "'build_renderable' should not mark required if mapping==none" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @path,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:required) == @expected_required
  end

  @variable %Variable{mapping: :out}
  @path ["variables", "input", "age"]
  @expected_required ""

  test "'build_renderable' should not mark required if mapping==out" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @path,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:required) == @expected_required
  end

  @variable %Variable{mapping: :in_optional}
  @path ["variables", "input", "age"]
  @expected_required ""

  test "'build_renderable' should not mark required if mapping==in_optional" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @path,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:required) == @expected_required
  end

  @variable %Variable{mapping: :in_required}
  @path ["variables", "input", "age"]
  @expected_required "*"

  test "'build_renderable' should not mark required if mapping==in_required" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @path,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:required) == @expected_required
  end

  # Enum property

  @variable %Variable{
    enum: ["Bill", "Bob"]
  }

  @expected_enum "Bill, Bob"
  @path ["variables", "input", "name"]

  test "'build_renderable' should build proper enum string" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @path,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:enum) == @expected_enum
  end

  # Indentation property

  @variable %Variable{}

  @path ["variables", "input", "parent1", "parent2", "name"]

  @expected_indentation "- - - - "

  test "'build_renderable' should build proper indentation string" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @path,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:indentation) == @expected_indentation
  end

  @variable %Variable{}

  @path ["variables", "input", "name"]

  @expected_indentation ""

  test "'build_renderable' should build proper no-indentation string" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @path,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:indentation) == @expected_indentation
  end

  # Row class property

  # Not tested since it could change very often
end
