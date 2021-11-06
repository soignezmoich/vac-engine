defmodule VacEngine.Processor.BlueprintTest do
  use VacEngine.DataCase

  import Ecto.Query
  alias VacEngine.Repo
  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Processor.Compiler
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Expression
  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Condition

  @hashes %{
    "7XZBRP9BZ7KX564ZAX7FTAXBYPRCG68E8S2TY4XESZSRSF36G4ASF55S" => [
      :hash0_test,
      :hash1_test,
      :hash2_test
    ],
    "RKBZZXY82ZXTYS29EEB3YBC5R2FP7HKBGZY6AY4CB87H63T8T5X7WT95" => [:hash3_test]
  }

  setup_all do
    [blueprints: Fixtures.Blueprints.blueprints()]
  end

  setup do
    Repo.query("delete from publications;")
    Repo.query("delete from blueprints;")
    Repo.query("delete from roles;")
    Repo.query("delete from portals;")
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})
    [workspace: workspace]
  end

  test "interface hash", %{blueprints: blueprints, workspace: workspace} do
    brs =
      blueprints
      |> Enum.map(fn {name, blueprint} ->
        assert {:ok, blueprint} =
                 Processor.create_blueprint(workspace, blueprint)

        {name, blueprint}
      end)
      |> Map.new()

    for {n, keys} <- @hashes do
      for k <- keys do
        br = Map.get(brs, k)
        assert n == br.interface_hash
      end
    end
  end

  test "manipulate variables", %{workspace: workspace} do
    assert {:ok, blueprint} =
             Processor.create_blueprint(workspace, %{name: "Test"})

    assert {:error, changeset} =
             Processor.create_variable(blueprint, %{
               name: "gender",
               type: :string,
               enum: ["f", "m"],
               children: [%{name: "sub", type: :string}]
             })

    assert {"only map and map[] can have children", []} =
             changeset.errors[:children]

    assert {:ok, variable} =
             Processor.create_variable(blueprint, %{
               name: "gender",
               type: :map,
               enum: ["f", "m"],
               children: [%{name: "sub", type: :string}]
             })

    assert {:error, _} =
             Processor.update_variable(variable, %{
               name: "newname",
               type: :integer
             })

    blueprint =
      Processor.get_blueprint!(blueprint.id, fn query ->
        query
        |> Processor.load_blueprint_variables()
      end)

    variable = Map.fetch!(blueprint.variable_path_index, ["gender", "sub"])

    assert {:ok, _variable} = Processor.delete_variable(variable)

    blueprint =
      Processor.get_blueprint!(blueprint.id, fn query ->
        query
        |> Processor.load_blueprint_variables()
      end)

    variable = Map.fetch!(blueprint.variable_path_index, ["gender"])

    assert {:ok, variable} =
             Processor.update_variable(variable, %{
               name: "newname",
               enum: [3, 4],
               type: :integer
             })

    assert [3, 4] == variable.enum

    assert "newname" == variable.name
    assert :integer == variable.type

    assert {:ok, variable} =
             Processor.update_variable(variable, %{
               name: "newname",
               type: :string
             })

    assert :string == variable.type
    assert nil == variable.enum
  end

  test "move variables", %{workspace: workspace} do
    assert {:ok, blueprint} =
             Processor.create_blueprint(workspace, %{
               name: "Test",
               variables: %{
                 parent: %{
                   type: "map[]",
                   children: %{
                     sub: %{
                       type: "map",
                       children: %{
                         subsub: %{
                           type: "integer"
                         }
                       }
                     }
                   }
                 },
                 sib: %{
                   type: "map[]"
                 }
               },
               deductions: [
                 %{
                   branches: [
                     %{
                       conditions: [
                         %{
                           expression:
                             quote(do: var(["parent", 4, "sub", "subsub"]))
                         }
                       ],
                       assignments: [
                         %{
                           target: ["parent", 3, "sub"],
                           expression: 23
                         }
                       ]
                     }
                   ]
                 }
               ]
             })

    blueprint =
      Processor.get_blueprint!(blueprint.id, fn query ->
        query
        |> Processor.load_blueprint_variables()
      end)

    var = Map.fetch!(blueprint.variable_path_index, ["parent", "sub"])
    sib = Map.fetch!(blueprint.variable_path_index, ["sib"])

    assert {:ok, var} = Processor.move_variable(var, sib)

    blueprint =
      Processor.get_blueprint!(blueprint.id, fn query ->
        query
        |> Processor.load_blueprint_variables()
        |> Processor.load_blueprint_full_deductions()
      end)

    target =
      get_in(blueprint, [
        Access.key(:deductions),
        Access.at(0),
        Access.key(:branches),
        Access.at(0),
        Access.key(:assignments),
        Access.at(0),
        Access.key(:target)
      ])

    assert ["sib", 0, "sub"] == target

    assert {:ok, _var} = Processor.move_variable(var, blueprint)

    blueprint =
      Processor.get_blueprint!(blueprint.id, fn query ->
        query
        |> Processor.load_blueprint_variables()
        |> Processor.load_blueprint_full_deductions()
      end)

    target =
      get_in(blueprint, [
        Access.key(:deductions),
        Access.at(0),
        Access.key(:branches),
        Access.at(0),
        Access.key(:assignments),
        Access.at(0),
        Access.key(:target)
      ])

    assert ["sub"] == target
  end

  test "update blueprint", %{workspace: workspace, blueprints: blueprints} do
    assert {:ok, blueprint} =
             Processor.create_blueprint(workspace, blueprints.simple_test)

    assert 10 == from(e in Expression, select: count(e.id)) |> Repo.one()
    assert 4 == from(e in Assignment, select: count(e.id)) |> Repo.one()
    assert 3 == from(e in Condition, select: count(e.id)) |> Repo.one()

    assert {:ok, blueprint} =
             Processor.update_blueprint(blueprint, blueprints.sig_test)

    assert 3 == from(e in Expression, select: count(e.id)) |> Repo.one()
    assert 1 == from(e in Assignment, select: count(e.id)) |> Repo.one()
    assert 1 == from(e in Condition, select: count(e.id)) |> Repo.one()

    assert {:ok, blueprint} =
             Processor.update_blueprint(blueprint, blueprints.nested_test)

    assert 13 == from(e in Expression, select: count(e.id)) |> Repo.one()
    assert 10 == from(e in Assignment, select: count(e.id)) |> Repo.one()
    assert 3 == from(e in Condition, select: count(e.id)) |> Repo.one()

    assert {:ok, _blueprint} =
             Processor.update_blueprint(blueprint, blueprints.simple_test)

    assert 10 == from(e in Expression, select: count(e.id)) |> Repo.one()
    assert 4 == from(e in Assignment, select: count(e.id)) |> Repo.one()
    assert 3 == from(e in Condition, select: count(e.id)) |> Repo.one()
  end

  test "invalid expressions" do
    br = %Blueprint{
      variables: [],
      deductions: [
        %Deduction{
          branches: [
            %Branch{
              conditions: [
                %Condition{
                  expression: %Expression{ast: {:var, [], []}}
                }
              ]
            }
          ]
        }
      ]
    }

    assert {:error, "invalid_var: invalid call of var/1"} ==
             Compiler.compile_blueprint(br)
  end
end
