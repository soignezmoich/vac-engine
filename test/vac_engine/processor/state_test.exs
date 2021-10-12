defmodule VacEngine.Processor.StateTest do
  use VacEngine.DataCase

  import Fixtures.Blueprints
  alias VacEngine.Account
  alias VacEngine.Processor.State
  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint

  test "map inputs" do
    br = Map.get(blueprints(), :map_test)

    input =
      %{
        list: [
          %{
            name: "name1",
            ignore: "i",
            nested: [%{nested: [1, 2, 3]}]
          },
          %{
            name: "name2",
            ignore: "i",
            nested: [%{nested: [4, 5, 6]}]
          }
        ],
        int: 3,
        str: "somestr",
        num: 2.4,
        ignore: "i",
        map: %{
          nlist: [1, 2, 3],
          nmap: %{name: "name3"},
          nlist2: [%{nested: 1}, %{nested: 3, ignore: []}]
        }
      }
      |> smap()

    expected_input =
      %{
        list: [
          %{
            name: "name1",
            nested: [%{nested: [1, 2, 3]}]
          },
          %{
            name: "name2",
            nested: [%{nested: [4, 5, 6]}]
          }
        ],
        int: 3,
        str: "somestr",
        num: 2.4,
        map: %{
          nlist: [1, 2, 3],
          nmap: %{name: "name3"},
          nlist2: [%{nested: 1}, %{nested: 3}]
        }
      }
      |> smap()

    expected_stack =
      %{
        list: %{
          0 => %{
            name: "name1",
            nested: %{0 => %{nested: %{0 => 1, 1 => 2, 2 => 3}}}
          },
          1 => %{
            name: "name2",
            nested: %{0 => %{nested: %{0 => 4, 1 => 5, 2 => 6}}}
          }
        },
        int: 3,
        str: "somestr",
        num: 2.4,
        map: %{
          nlist: %{0 => 1, 1 => 2, 2 => 3},
          nmap: %{name: "name3"},
          nlist2: %{0 => %{nested: 1}, 1 => %{nested: 3}}
        }
      }
      |> smap()

    expected_output =
      %{
        list: [
          %{
            nested: [%{nested: [1, 2, 3]}]
          },
          %{
            nested: [%{nested: [4, 5, 6]}]
          }
        ]
      }
      |> smap()

    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})
    assert {:ok, blueprint} = Processor.create_blueprint(workspace, br)

    state = State.new(blueprint.variables)

    state = State.map_input(state, input)
    state = State.finalize_output(state)

    assert state.input == expected_input
    assert state.stack == expected_stack
    assert state.output == expected_output
  end
end
