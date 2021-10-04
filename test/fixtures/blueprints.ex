defmodule Fixtures.Blueprints do
  Module.register_attribute(__MODULE__, :blueprint, accumulate: true)

  @blueprint %{
    name: :simple_test,
    variables: %{
      aint: %{type: :integer, input: true, output: false, default: 0},
      bint: %{type: :integer, input: true, output: true, default: 0},
      cint: %{type: :integer, input: true, output: true, default: 0}
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
              %{target: :aint, expression: 72},
              %{target: :bint, expression: quote(do: add(1, @aint))},
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
              %{target: :cint, expression: quote(do: add(@aint, 1))}
            ]
          }
        ]
      }
    ]
  }

  @blueprint %{
    name: :nested_test,
    variables: %{
      enum_string: %{
        type: "string",
        input: true,
        validators: [
          %{expression: quote(do: contains(["v1", "v2"], @self))}
        ]
      },
      obj_list: %{
        type: "map[]",
        input: true,
        children: %{
          child_int: %{type: :integer, input: true},
          child_object: %{
            type: :map,
            input: true,
            children: %{
              grand_child_int: %{type: :integer, input: true}
            }
          }
        }
      },
      int_list: %{
        type: "integer[]",
        input: true,
        output: true
      },
      dnest: %{
        type: "map[]",
        output: true,
        children: %{
          dnest2: %{
            type: "map[]",
            output: true,
            children: %{
              dnest3: %{type: :string, output: true}
            }
          }
        }
      },
      map_list: %{
        type: "map[]",
        output: true,
        children: %{
          child_string: %{type: :string, output: true},
          child_int: %{type: :integer, output: true},
          child_object: %{
            type: :map,
            output: true,
            children: %{
              grand_child_int: %{type: :integer, output: true},
              grand_child_map: %{
                type: :map,
                output: true,
                children: %{
                  grand_grand_child_ints: %{type: "integer[]", output: true}
                }
              }
            }
          }
        }
      }
    },
    deductions: [
      %{
        branches: [
          %{
            conditions: [],
            assignements: [
              %{target: [:int_list, 2], expression: 54},
              %{target: [:dnest, 2, :dnest2, 4, :dnest3], expression: "nested"},
              %{target: [:map_list, 4, :child_int], expression: 45},
              %{
                target: [:map_list, 1, :child_object, :grand_child_int],
                expression: 15
              },
              %{
                target: [
                  :map_list,
                  1,
                  :child_object,
                  :grand_child_map,
                  :grand_grand_child_ints
                ],
                expression: [1, 2, 3]
              }
            ]
          }
        ]
      },
      %{
        branches: [
          %{
            conditions: [],
            assignements: [
              %{target: [:map_list, 2, :child_int], expression: 25},
              %{
                target: [:map_list, 3, :child_object, :grand_child_int],
                expression: 35
              }
            ]
          }
        ]
      },
      %{
        branches: [
          %{
            conditions: [
              %{
                expression:
                  {:gt, [signature: {{:integer, :integer}, :boolean}],
                   [
                     {:var, [signature: {{:any}, :integer}], [[:int_list, 2]]},
                     32
                   ]}
              }
            ],
            assignements: [
              %{target: :enum_string, expression: "v1"},
              %{target: :int_list, expression: [1, 2, 3]}
            ]
          }
        ]
      }
    ]
  }

  @blueprint %{
    name: :ruleset0,
    variables: %{
      gender: %{
        type: :string,
        input: true
      },
      pregnant: %{
        type: :string,
        input: true
      },
      high_risk: %{
        type: :boolean,
        input: true
      },
      immuno: %{
        type: :boolean,
        input: true
      },
      immuno_discussed: %{
        type: :boolean,
        input: true
      },
      immuno_recommended: %{
        type: :boolean,
        input: true
      },
      healthcare_worker: %{
        type: :boolean,
        input: true
      },
      high_risk_contact: %{
        type: :boolean,
        input: true
      },
      immuno_contact: %{
        type: :boolean,
        input: true
      },
      community_facility: %{
        type: :boolean,
        input: true
      },
      infection_date: %{
        type: :date,
        input: true
      },
      vaccine_allergy: %{
        type: :boolean,
        input: true
      },
      vaccine_compatibilities: %{
        type: "map[]",
        output: true,
        children: %{
          compatible: %{type: :boolean, output: true}
        }
      }
    },
    deductions: [
      %{
        branches: [
          %{
            conditions: [
              %{expression: quote(do: lt(@age, 12))}
            ],
            assignements: [
              %{
                target: [:vaccine_compatibilities, 0, :boolean],
                expression: false
              },
              %{
                target: [:vaccine_compatibilities, 1, :boolean],
                expression: false
              }
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
