defmodule VacEngine.EditorLive.VariableListComponentTest do
  use ExUnit.Case

  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Blueprint
  alias VacEngineWeb.EditorLive.VariableListComponent

  # empty variable list

  @blueprint %Blueprint{
    input_variables: [],
    intermediate_variables: [],
    output_variables: []
  }

  @renderable %{
    input_variables: [],
    intermediate_variables: [],
    output_variables: []
  }

  test "'build' should build a renderable from an empty variable list" do
    assert VariableListComponent.build_renderable(@blueprint) == @renderable
  end

  # non empty variable list

  @blueprint %Blueprint{
    input_variables: [
      %Variable{
        mapping: :in_required,
        children: [],
        name: "in_required",
        path: ~w(in_required)
      },
      %Variable{
        mapping: :in_optional,
        children: [],
        name: "in_optional",
        path: ~w(in_optional)
      }
    ],
    intermediate_variables: [
      %Variable{
        mapping: nil,
        children: [],
        name: "intermediate",
        path: ~w(intermediate)
      }
    ],
    output_variables: [
      %Variable{mapping: :out, children: [], name: "out", path: ~w(out)}
    ]
  }

  @renderable %{
    input_variables: [
      %Variable{
        mapping: :in_required,
        children: [],
        name: "in_required",
        path: ~w(in_required)
      },
      %Variable{
        mapping: :in_optional,
        children: [],
        name: "in_optional",
        path: ~w(in_optional)
      }
    ],
    intermediate_variables: [
      %Variable{
        mapping: nil,
        children: [],
        name: "intermediate",
        path: ~w(intermediate)
      }
    ],
    output_variables: [
      %Variable{mapping: :out, children: [], name: "out", path: ~w(out)}
    ]
  }

  test "'build' should build a renderable from an non-empty variable list" do
    assert VariableListComponent.build_renderable(@blueprint) == @renderable
  end

  # non empty variable list - nested variables

  @blueprint %Blueprint{
    input_variables: [],
    intermediate_variables: [],
    output_variables: [
      %Variable{
        mapping: :out,
        children: [
          %Variable{
            mapping: :out,
            children: [],
            name: "out_nested",
            path: ~w(out out_nested)
          }
        ],
        name: "out",
        path: ~w(out)
      },
      %Variable{
        mapping: :out,
        children: [],
        name: "out_nested",
        path: ~w(out out_nested)
      }
    ]
  }

  @renderable %{
    input_variables: [],
    intermediate_variables: [],
    output_variables: [
      %Variable{
        mapping: :out,
        children: [
          %Variable{
            mapping: :out,
            children: [],
            name: "out_nested",
            path: ~w(out out_nested)
          }
        ],
        name: "out",
        path: ~w(out)
      },
      %Variable{
        mapping: :out,
        children: [],
        name: "out_nested",
        path: ~w(out out_nested)
      }
    ]
  }

  test "'build' should build a renderable from an non-empty nested variable list" do
    assert VariableListComponent.build_renderable(@blueprint) == @renderable
  end
end
