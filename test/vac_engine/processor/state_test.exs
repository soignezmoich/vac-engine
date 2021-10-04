defmodule VacEngine.Processor.StateTest do
  use VacEngine.ProcessorCase

  alias VacEngine.Processor.State
  alias VacEngine.Blueprints
  alias VacEngine.Blueprints.Blueprint

  test "map inputs" do
    blueprint = %{
      name: :map_test,
      variables: %{
        list: %{
          type: "map[]",
          input: true,
          output: true,
          children: %{
            name: %{type: :string, input: true},
            nested: %{
              type: "map[]",
              input: true,
              output: true,
              children: %{
                nested: %{type: "integer[]", input: true, output: true}
              }
            }
          }
        },
        int: %{
          type: "integer",
          input: true
        },
        str: %{
          type: "string",
          input: true
        },
        num: %{
          type: "number",
          input: true
        },
        ignore: %{
          type: "string",
          output: true
        },
        map: %{
          type: :map,
          input: true,
          children: %{
            nlist: %{type: "integer[]", input: true},
            nmap: %{
              type: :map,
              input: true,
              children: %{
                name: %{type: :string, input: true}
              }
            },
            nlist2: %{
              type: "map[]",
              input: true,
              children: %{
                nested: %{type: :integer, input: true}
              }
            }
          }
        }
      }
    }

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

    assert {:ok, blueprint} =
             Blueprints.change_blueprint(%Blueprint{}, blueprint)
             |> Ecto.Changeset.apply_action(:insert)

    state = State.new(blueprint.variables)

    state = State.map_input(state, input)
    state = State.finalize_output(state)

    assert state.input == expected_input
    assert state.stack == expected_stack
    assert state.output == expected_output

  end
end
