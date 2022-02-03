defmodule Fixtures.SimulationStacks do
  import Fixtures.Helpers
  use Fixtures.Helpers.SimulationStacks

  stack(:test_all) do
    %{
      blueprint: :simple_test,
      stack: %{
        active: true,
        layers: [
          %{
            case: %{
              name: "template",
              input_entries: [
                %{key: "aint", value: "80"},
                %{key: "bint", value: "10"},
                %{key: "cint", value: "4"}
              ]
            }
          },
          %{
            case: %{
              name: "test",
              input_entries: [
                %{key: "aint", value: "2000"}
              ],
              output_entries: [
                %{key: "aint", forbid: true},
                %{key: "bint", expected: "10"},
                %{key: "cint", expected: "2001"}
              ]
            }
          }
        ]
      }
    }
  end
end
