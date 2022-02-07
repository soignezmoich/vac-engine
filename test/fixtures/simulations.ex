defmodule Fixtures.Simulations do
  @moduledoc false

  use Fixtures.Helpers.Simulations

  sim do
    %{
      blueprint: :simple_test,
      input: %{
        aint: 2000,
        bint: 10,
        cint: 4
      },
      result: %{
        aint: %{forbid: true, present_while_forbidden: false},
        bint: %{expected: 10, match: true}
      }
    }
  end

  sim do
    %{
      blueprint: :simple_test,
      input: %{
        aint: 2000,
        bint: 10,
        cint: 4
      },
      result: %{
        aint: %{expected: 50, match: false},
        bint: %{forbid: true, present_while_forbidden: true}
      }
    }
  end

  sim do
    %{
      blueprint: :simple_test,
      input: %{
        bint: 10,
        cint: 4
      },
      error: "variable aint is required"
    }
  end

  sim do
    %{
      blueprint: :simple_test,
      result: %{
        aint: %{present_while_forbidden: false},
        bint: %{match: true}
      },
      stack: %{
        active: true,
        layers: [
          %{
            case: %{
              name: "template",
              input_entries: [
                %{key: "aint", value: "82"},
                %{key: "bint", value: "13"},
                %{key: "cint", value: "5"}
              ]
            }
          },
          %{
            case: %{
              name: "test",
              input_entries: [
                %{key: "aint", value: "400"}
              ],
              output_entries: [
                %{key: "aint", forbid: true},
                %{key: "bint", expected: "13"},
                %{key: "cint", expected: "2001"}
              ]
            }
          }
        ]
      }
    }
  end
end
