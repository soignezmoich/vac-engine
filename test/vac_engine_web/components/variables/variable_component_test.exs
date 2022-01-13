defmodule VacEngine.EditorLive.VariableComponentTest do
  use ExUnit.Case

  alias VacEngine.Processor.Variable
  alias VacEngineWeb.EditorLive.VariableComponent

  # Name property

  @variable %Variable{name: "age", path: ~w(age)}
  @expected_name "age"
  @even true
  @selection_path nil

  test "'build_renderable' should build proper name" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:name) == @expected_name
  end

  # Type property

  @variable %Variable{type: :integer, path: ~w(age)}
  @expected_type :integer

  test "'build_renderable' should build proper type" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:type) == @expected_type
  end

  # Required property

  @variable %Variable{mapping: nil, path: ~w(age)}
  @expected_required ""

  test "'build_renderable' should not mark required if mapping==nil" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:required) == @expected_required
  end

  @variable %Variable{mapping: :none, path: ~w(age)}
  @expected_required ""

  test "'build_renderable' should not mark required if mapping==none" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:required) == @expected_required
  end

  @variable %Variable{mapping: :out, path: ~w(age)}
  @expected_required ""

  test "'build_renderable' should not mark required if mapping==out" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:required) == @expected_required
  end

  @variable %Variable{mapping: :in_optional, path: ~w(age)}
  @expected_required ""

  test "'build_renderable' should not mark required if mapping==in_optional" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:required) == @expected_required
  end

  @variable %Variable{mapping: :in_required, path: ~w(age)}
  @expected_required "*"

  test "'build_renderable' should not mark required if mapping==in_required" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:required) == @expected_required
  end

  # Enum property

  @variable %Variable{
    enum: ["Bill", "Bob"],
    path: ~w(age)
  }

  @expected_enum "Bill, Bob"

  test "'build_renderable' should build proper enum string" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:enum) == @expected_enum
  end

  # Indentation property

  @variable %Variable{path: ~w(parent1 parent2 name)}

  @expected_indentation "   └─"

  test "'build_renderable' should build proper indentation string" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:indentation) == @expected_indentation
  end

  @variable %Variable{path: ~w(age)}

  @expected_indentation ""

  test "'build_renderable' should build proper no-indentation string" do
    renderable =
      VariableComponent.build_renderable(
        @variable,
        @even,
        @selection_path
      )

    assert renderable |> Map.get(:indentation) == @expected_indentation
  end

  # Row class property

  # Not tested since it could change very often
end
