defmodule VacEngine.Editor.Renderables.DeductionRenderableTest do
  use ExUnit.Case

  alias VacEngineWeb.Editor.DeductionRenderable

  @deduction %VacEngine.Processor.Deduction{
    blueprint_id: 5,
    branches: [
      %VacEngine.Processor.Branch{
        assignments: [
          %VacEngine.Processor.Assignment{
            blueprint_id: 5,
            branch_id: 14475,
            column: %VacEngine.Processor.Column{
              blueprint_id: 5,
              deduction_id: 6022,
              description: nil,
              id: 26372,
              position: 0,
              type: :assignment,
              variable: nil,
              workspace_id: 1
            },
            column_id: 26372,
            deduction_id: 6022,
            description: nil,
            expression: %VacEngine.Processor.Expression{
              assignment_id: 24334,
              ast:
                {:age, [signature: {[:date], :integer}],
                 [{:var, [signature: {[:name], :date}], [["birthdate"]]}]},
              bindings: [
                %VacEngine.Processor.Binding{
                  blueprint_id: 5,
                  elements: [
                    %VacEngine.Processor.BindingElement{
                      binding_id: 68917,
                      blueprint_id: 5,
                      id: 163_871,
                      index: nil,
                      position: 0,
                      variable_id: 22751,
                      workspace_id: 1
                    }
                  ],
                  expression_id: 67318,
                  id: 68917,
                  position: -1,
                  workspace_id: 1
                },
                %VacEngine.Processor.Binding{
                  blueprint_id: 5,
                  elements: [
                    %VacEngine.Processor.BindingElement{
                      binding_id: 68918,
                      blueprint_id: 5,
                      id: 163_872,
                      index: nil,
                      position: 0,
                      variable_id: 22752,
                      workspace_id: 1
                    }
                  ],
                  expression_id: 67318,
                  id: 68918,
                  position: 0,
                  workspace_id: 1
                }
              ],
              blueprint_id: 5,
              column_id: nil,
              condition_id: nil,
              id: 67318,
              variable_id: nil,
              workspace_id: 1
            },
            id: 24334,
            target: ["age"],
            workspace_id: 1
          }
        ],
        blueprint_id: 5,
        conditions: [],
        deduction_id: 6022,
        description: nil,
        id: 14475,
        position: 0,
        workspace_id: 1
      }
    ],
    columns: [
      %VacEngine.Processor.Column{
        blueprint_id: 5,
        deduction_id: 6022,
        description: nil,
        expression: %VacEngine.Processor.Expression{
          assignment_id: nil,
          ast: nil,
          bindings: [
            %VacEngine.Processor.Binding{
              blueprint_id: 5,
              elements: [
                %VacEngine.Processor.BindingElement{
                  binding_id: 68916,
                  blueprint_id: 5,
                  id: 163_870,
                  index: nil,
                  position: 0,
                  variable_id: 22751,
                  workspace_id: 1
                }
              ],
              expression_id: 67317,
              id: 68916,
              position: -1,
              workspace_id: 1
            }
          ],
          blueprint_id: 5,
          column_id: 26372,
          condition_id: nil,
          id: 67317,
          variable_id: nil,
          workspace_id: 1
        },
        id: 26372,
        position: 0,
        type: :assignment,
        variable: ["age"],
        workspace_id: 1
      }
    ],
    description: nil,
    id: 6022,
    position: 0,
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

  test "'build_deduction' should build valid renderable" do
    throw("NOT IMPLEMENTED")
  end
end
