defmodule Fixtures.Blueprints do
  Module.register_attribute(__MODULE__, :blueprint, accumulate: true)

  # @blueprint %{
  #  name: :test,
  #  variables: %{
  #    birthdate: %{type: :date, input: true, output: false},
  #    immuno_suppressed: %{type: :boolean, input: true, output: false},
  #    priority: %{
  #      type: :enum,
  #      input: false,
  #      output: true,
  #      values: [
  #        :high,
  #        :low
  #      ]
  #    },
  #    age_1: %{type: :integer, input: false, output: true},
  #    age_2: %{type: :integer, input: false, output: true},
  #  },
  #  functions: [
  #    %{
  #      # not strictly necessary
  #      arguments: [:birthdate, :immuno_suppressed],
  #      # not strictly necessary
  #      returns: [:priority],
  #      branches: [
  #        %{
  #          conditions: [
  #            %{name: :age, expression: quote(do: gt(age_now(@birthdate), 75))},
  #            %{
  #              name: :immuno,
  #              expression: quote(do: is_false(@immuno_suppressed))
  #            }
  #          ],
  #          assignements: [
  #            %{variable: :age_1, expression: quote(do: add(1, @age))},
  #            %{variable: :age_2, expression: quote(do: add(2, @age))},
  #          ]
  #        }
  #      ]
  #    }
  #  ]
  # }
  @blueprint %{
    name: :test,
    variables: %{
      aint: %{type: :integer, input: true, output: false, default: 0},
      bint: %{type: :integer, input: true, output: false, default: 0}
    },
    functions: [
      %{
        branches: [
          %{
            conditions: [
              %{expression: quote(do: gt(@aint, 75))},
              %{expression: quote(do: lt(@aint, 200))}
            ],
            assignements: [
              %{variable: :aint, expression: quote(do: add(1, @aint))},
              %{variable: :cint, expression: quote(do: add(2, @bint))}
            ]
          }
        ]
      },
      %{
        branches: [
          %{
            conditions: [
              %{expression: quote(do: gt(@aint, 200))}
            ],
            assignements: [
              %{variable: :aint, expression: quote(do: add(@aint, 1))}
            ]
          }
        ]
      }
    ]
  }

  def blueprints() do
    @blueprint
  end
end
