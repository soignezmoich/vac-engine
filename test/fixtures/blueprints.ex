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
    deductions: [
      %{
        branches: [
          %{
            conditions: [
              %{expression: quote(do: gt(@aint, 75))},
              %{expression: quote(do: lt(@aint, 200))}
            ],
            assignements: [
              %{target: :aint, expression: quote(do: add(1, @aint))},
              %{target: :cint, expression: quote(do: add(2, @bint))}
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
              %{target: :aint, expression: quote(do: add(@aint, 1))}
            ]
          }
        ]
      }
    ]
  }

#  @data %{
#    past_injections: [
#      %{date: "2019"}
#    ]
#  }
#
#  @blueprint %{
#    name: :test,
#    variables: %{
#      past_injections: %{type: :any, input: true, output: false, default: []},
#      past_injection_date: %{type: :date, input: false, output: false}
#    },
#    steps: [
#      %{
#        branches: [
#          %{
#            conditions: [
#              %{expression: quote(do: exists(@past_injections, "*.date"))}
#            ],
#            assignements: [
#              %{
#                variable: :last_injection_date,
#                expression:
#                  quote(do: get(sort(@past_injections, "-date"), "last.date"))
#              }
#            ]
#          }
#        ]
#      }
#    ]
#  }
#
#  @blueprint %{
#    name: :test,
#    variables: %{
#      past_injections: %{type: :any, input: true, output: false, default: []},
#      has_past_injection: %{type: :boolean, input: false, output: false}
#    },
#    steps: [
#      %{
#        branches: [
#          %{
#            conditions: [],
#            assignements: [
#              %{
#                target: :has_past_injection,
#                expression: quote(do: exists(@past_injections, "*.date"))
#              }
#            ]
#          }
#        ]
#      }
#    ]
#  }
#
#  @blueprint %{
#    name: :test,
#    variables: %{
#      vaccine_sequence: %{type: :array, input: false, output: true,
#        children: %{
#      date: %{type: :date, input: false, output: true,
#        }
#        }
#    },
#    steps: [
#      %{
#        branches: [
#          %{
#            conditions: [%{expression: false}],
#            assignements: [
#              %{
#                target: "vaccine_sequence.0.date",
#                expression: quote(do: months_from_now(6))
#              },
#              %{
#                target: "vaccine_sequence.0.vaccine",
#                expression: quote(do: "moderna")
#              }
#            ]
#          },
#          %{
#            conditions: [%{expression: true}],
#            assignements: [
#              %{
#                target: "vaccine_sequence.1.date",
#                expression: quote(do: months_from_now(6))
#              },
#              %{
#                target: "vaccine_sequence.1.vaccine",
#                expression: quote(do: "pfizer")
#              }
#            ]
#          }
#        ]
#      }
#    ]
#  }

  def blueprints() do
    @blueprint
  end
end
