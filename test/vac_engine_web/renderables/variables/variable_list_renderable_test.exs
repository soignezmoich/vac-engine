defmodule VacEngine.Editor.Renderables.VariableRenderableTest do
  use ExUnit.Case

  alias VacEngine.Processor.Variable
  alias VacEngineWeb.Editor.VariableListRenderable

  # empty variable list

  @variable_list []

  @renderable %{
    input: [],
    intermediate: [],
    output: []
  }

  test "'build' should build a renderable from an empty variable list" do
    assert VariableListRenderable.build(@variable_list) == @renderable
  end

  # non empty variable list

  @variable_list [
    %Variable{mapping: :out, children: [], name: "out"},
    %Variable{mapping: :in_required, children: [], name: "in_required"},
    %Variable{mapping: :in_optional, children: [], name: "in_optional"},
    %Variable{mapping: nil, children: [], name: "intermediate"}
  ]

  @renderable %{
    input: [
      {["variables", "input", "in_required"],
       %Variable{mapping: :in_required, children: [], name: "in_required"}},
      {["variables", "input", "in_optional"],
       %Variable{mapping: :in_optional, children: [], name: "in_optional"}}
    ],
    intermediate: [
      {["variables", "intermediate", "intermediate"],
       %Variable{mapping: nil, children: [], name: "intermediate"}}
    ],
    output: [
      {["variables", "output", "out"],
       %Variable{mapping: :out, children: [], name: "out"}}
    ]
  }

  test "'build' should build a renderable from an non-empty variable list" do
    assert VariableListRenderable.build(@variable_list) == @renderable
  end

  # non empty variable list - nested variables

  @variable_list [
    %Variable{
      mapping: :out,
      children: [%Variable{mapping: :out, children: [], name: "out_nested"}],
      name: "out"
    }
  ]

  @renderable %{
    input: [],
    intermediate: [],
    output: [
      {["variables", "output", "out"],
       %Variable{
         mapping: :out,
         children: [%Variable{mapping: :out, children: [], name: "out_nested"}],
         name: "out"
       }},
      {["variables", "output", "out", "out_nested"],
       %Variable{mapping: :out, children: [], name: "out_nested"}}
    ]
  }

  test "'build' should build a renderable from an non-empty nested variable list" do
    assert VariableListRenderable.build(@variable_list) == @renderable
  end
end
