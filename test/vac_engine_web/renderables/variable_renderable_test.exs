defmodule VacEngine.Editor.Renderables.VariableRenderableTest do
  use ExUnit.Case

  alias VacEngineWeb.Editor.VariableRenderable

  @variable %{
    __struct__: VacEngine.Processor.Variable,
    blueprint_id: 1,
    children: [],
    default: nil,
    default_id: nil,
    description: nil,
    enum: nil,
    id: 1,
    input: false,
    inserted_at: ~U[2021-10-19 19:45:55Z],
    mapping: :out,
    name: "age",
    output: false,
    parent_id: nil,
    path: ["age"],
    type: :integer,
    updated_at: ~U[2021-10-19 19:45:55Z],
    workspace_id: 1
  }

  @renderable %{
    dot_path: "input.age",
    enum: [],
    name: "age",
    path: ["input", "age"],
    selected: false,
    type: :integer
  }

  test "'build_variables' should build valid renderable" do
    assert VariableRenderable.build_variable({["input", "age"], @variable}, nil) ==
             @renderable
  end

  @variable %{
    __struct__: VacEngine.Processor.Variable,
    blueprint_id: 1,
    children: [],
    default: nil,
    default_id: nil,
    description: nil,
    enum: ["Bill", "Bob"],
    id: 1,
    input: false,
    inserted_at: ~U[2021-10-19 19:45:55Z],
    mapping: :out,
    name: "name",
    output: false,
    parent_id: nil,
    path: ["name"],
    type: :string,
    updated_at: ~U[2021-10-19 19:45:55Z],
    workspace_id: 1
  }

  @renderable %{
    dot_path: "input.name",
    enum: ["Bill", "Bob"],
    name: "name",
    path: ["input", "name"],
    selected: false,
    type: :string
  }

  test "'build_variables' should build string variables with enum" do
    assert VariableRenderable.build_variable(
             {["input", "name"], @variable},
             nil
           ) == @renderable
  end

  @variables [
    %{
      __struct__: VacEngine.Processor.Variable,
      blueprint_id: 1,
      children: [],
      default: nil,
      default_id: nil,
      description: nil,
      enum: nil,
      id: 1,
      input: false,
      inserted_at: ~U[2021-10-19 19:45:55Z],
      mapping: :in_required,
      name: "input_required",
      output: false,
      parent_id: nil,
      path: ["input_required"],
      type: :integer,
      updated_at: ~U[2021-10-19 19:45:55Z],
      workspace_id: 1
    },
    %{
      __struct__: VacEngine.Processor.Variable,
      blueprint_id: 1,
      children: [],
      default: nil,
      default_id: nil,
      description: nil,
      enum: nil,
      id: 2,
      input: false,
      inserted_at: ~U[2021-10-19 19:45:55Z],
      mapping: :in_optional,
      name: "input_optional",
      output: false,
      parent_id: nil,
      path: ["input_optional"],
      type: :integer,
      updated_at: ~U[2021-10-19 19:45:55Z],
      workspace_id: 1
    },
    %{
      __struct__: VacEngine.Processor.Variable,
      blueprint_id: 1,
      children: [],
      default: nil,
      default_id: nil,
      description: nil,
      enum: nil,
      id: 3,
      input: false,
      inserted_at: ~U[2021-10-19 19:45:55Z],
      mapping: :out,
      name: "output1",
      output: false,
      parent_id: nil,
      path: ["output1"],
      type: :integer,
      updated_at: ~U[2021-10-19 19:45:55Z],
      workspace_id: 1
    },
    %{
      __struct__: VacEngine.Processor.Variable,
      blueprint_id: 1,
      children: [],
      default: nil,
      default_id: nil,
      description: nil,
      enum: nil,
      id: 4,
      input: false,
      inserted_at: ~U[2021-10-19 19:45:55Z],
      mapping: :out,
      name: "output2",
      output: false,
      parent_id: nil,
      path: ["output2"],
      type: :integer,
      updated_at: ~U[2021-10-19 19:45:55Z],
      workspace_id: 1
    },
    %{
      __struct__: VacEngine.Processor.Variable,
      blueprint_id: 1,
      children: [],
      default: nil,
      default_id: nil,
      description: nil,
      enum: nil,
      id: 3,
      input: false,
      inserted_at: ~U[2021-10-19 19:45:55Z],
      mapping: :none,
      name: "intermediate1",
      output: false,
      parent_id: nil,
      path: ["intermediate1"],
      type: :integer,
      updated_at: ~U[2021-10-19 19:45:55Z],
      workspace_id: 1
    }
  ]

  @renderable %{
    input: [
      %{
        dot_path: "input.input_required",
        enum: [],
        name: "input_required",
        path: ["input", "input_required"],
        selected: false,
        type: :integer
      },
      %{
        dot_path: "input.input_optional",
        enum: [],
        name: "input_optional",
        path: ["input", "input_optional"],
        selected: false,
        type: :integer
      }
    ],
    intermediate: [
      %{
        default: nil,
        dot_path: "intermediate.intermediate1",
        enum: [],
        name: "intermediate1",
        path: ["intermediate", "intermediate1"],
        selected: false,
        type: :integer
      }
    ],
    output: [
      %{
        default: nil,
        dot_path: "output.output1",
        enum: [],
        name: "output1",
        path: ["output", "output1"],
        selected: false,
        type: :integer
      },
      %{
        default: nil,
        dot_path: "output.output2",
        enum: [],
        name: "output2",
        path: ["output", "output2"],
        selected: false,
        type: :integer
      }
    ]
  }

  test "'build' should group variables by input / output mapping" do
    assert VariableRenderable.build(@variables, nil) == @renderable
  end

  @variables [
    %{
      __struct__: VacEngine.Processor.Variable,
      blueprint_id: 1,
      default: nil,
      default_id: nil,
      description: nil,
      enum: nil,
      id: 1,
      input: false,
      inserted_at: ~U[2021-10-19 19:45:55Z],
      mapping: :in_required,
      name: "parent",
      output: false,
      parent_id: nil,
      path: ["parent"],
      type: :map,
      updated_at: ~U[2021-10-19 19:45:55Z],
      workspace_id: 1,
      children: [
        %{
          __struct__: VacEngine.Processor.Variable,
          blueprint_id: 1,
          default: nil,
          default_id: nil,
          description: nil,
          enum: nil,
          id: 2,
          input: false,
          inserted_at: ~U[2021-10-19 19:45:55Z],
          mapping: :in_required,
          name: "child1",
          output: false,
          parent_id: nil,
          path: ["parent", "child1"],
          type: :map,
          updated_at: ~U[2021-10-19 19:45:55Z],
          workspace_id: 1,
          children: [
            %{
              __struct__: VacEngine.Processor.Variable,
              blueprint_id: 1,
              default: nil,
              default_id: nil,
              description: nil,
              enum: nil,
              id: 3,
              input: false,
              inserted_at: ~U[2021-10-19 19:45:55Z],
              mapping: :in_required,
              name: "grand_child",
              output: false,
              parent_id: nil,
              path: ["grand_child"],
              type: :integer,
              updated_at: ~U[2021-10-19 19:45:55Z],
              workspace_id: 1,
              children: []
            }
          ]
        },
        %{
          __struct__: VacEngine.Processor.Variable,
          blueprint_id: 1,
          default: nil,
          default_id: nil,
          description: nil,
          enum: nil,
          id: 4,
          input: false,
          inserted_at: ~U[2021-10-19 19:45:55Z],
          mapping: :in_required,
          name: "child2",
          output: false,
          parent_id: nil,
          path: ["child2"],
          type: :integer,
          updated_at: ~U[2021-10-19 19:45:55Z],
          workspace_id: 1,
          children: []
        }
      ]
    }
  ]

  test "'build' should handle variable trees" do
    assert VariableRenderable.build(@variables, nil) == %{
             input: [
               %{
                 dot_path: "input.parent",
                 enum: [],
                 name: "parent",
                 path: ["input", "parent"],
                 selected: false,
                 type: :map
               },
               %{
                 dot_path: "input.parent.child1",
                 enum: [],
                 name: "child1",
                 path: ["input", "parent", "child1"],
                 selected: false,
                 type: :map
               },
               %{
                 dot_path: "input.parent.child1.grand_child",
                 enum: [],
                 name: "grand_child",
                 path: ["input", "parent", "child1", "grand_child"],
                 selected: false,
                 type: :integer
               },
               %{
                 dot_path: "input.parent.child2",
                 enum: [],
                 name: "child2",
                 path: ["input", "parent", "child2"],
                 selected: false,
                 type: :integer
               }
             ],
             intermediate: [],
             output: []
           }
  end
end
