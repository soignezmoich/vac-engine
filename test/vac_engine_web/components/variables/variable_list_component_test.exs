defmodule VacEngine.Editor.VariableListComponentTest do
  use ExUnit.Case

  alias VacEngine.Processor.Variable
  alias VacEngineWeb.Editor.VariableListComponent

  # empty variable list

  @variable_list []

  @renderable %{
    input_variables: [],
    intermediate_variables: [],
    output_variables: []
  }

  test "'build' should build a renderable from an empty variable list" do
    assert VariableListComponent.build_renderable(@variable_list) == @renderable
  end

  # non empty variable list

  @variable_list [
    %Variable{mapping: :out, children: [], name: "out"},
    %Variable{mapping: :in_required, children: [], name: "in_required"},
    %Variable{mapping: :in_optional, children: [], name: "in_optional"},
    %Variable{mapping: nil, children: [], name: "intermediate"}
  ]

  @renderable %{
    input_variables: [
      %{
        path: ["in_required"],
        variable: %Variable{
          mapping: :in_required,
          children: [],
          name: "in_required"
        }
      },
      %{
        path: ["in_optional"],
        variable: %Variable{
          mapping: :in_optional,
          children: [],
          name: "in_optional"
        }
      }
    ],
    intermediate_variables: [
      %{
        path: ["intermediate"],
        variable: %Variable{mapping: nil, children: [], name: "intermediate"}
      }
    ],
    output_variables: [
      %{
        path: ["out"],
        variable: %Variable{mapping: :out, children: [], name: "out"}
      }
    ]
  }

  test "'build' should build a renderable from an non-empty variable list" do
    assert VariableListComponent.build_renderable(@variable_list) == @renderable
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
    input_variables: [],
    intermediate_variables: [],
    output_variables: [
      %{
        path: ["out"],
        variable: %Variable{
          mapping: :out,
          children: [%Variable{mapping: :out, children: [], name: "out_nested"}],
          name: "out"
        }
      },
      %{
        path: ["out", "out_nested"],
        variable: %Variable{mapping: :out, children: [], name: "out_nested"}
      }
    ]
  }

  test "'build' should build a renderable from an non-empty nested variable list" do
    assert VariableListComponent.build_renderable(@variable_list) == @renderable
  end
end
