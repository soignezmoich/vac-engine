defmodule Fixtures.Blueprints do
  import Fixtures.Helpers
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
            assignments: [
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
            assignments: [
              %{target: :cint, expression: quote(do: add(@aint, 1))}
            ]
          }
        ]
      }
    ]
  }

  @blueprint %{
    name: :sig_test,
    variables: [],
    deductions: [
      %{
        branches: [
          %{
            conditions: [
              %{
                expression:
                  {:gt, [signature: {[:integer, :integer], :boolean}],
                   [
                     {:var, [signature: {[:name], :integer}], ["age"]},
                     12
                   ]}
              }
            ],
            assignments: []
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
            conditions: [
              %{expression: quote(do: is_nil(@enum_string))}
            ],
            assignments: [
              %{
                target: [
                  :map_list,
                  1,
                  :child_object,
                  :grand_child_map,
                  :grand_grand_child_ints,
                  2
                ],
                expression: 42
              },
              %{target: [:int_list, 2], expression: 54},
              %{target: [:dnest, 2, :dnest2, 4, :dnest3], expression: "nested"},
              %{target: [:map_list, 4, :child_int], expression: 45},
              %{
                target: [:map_list, 1, :child_object, :grand_child_int],
                expression: 15
              }
            ]
          }
        ]
      },
      %{
        branches: [
          %{
            conditions: [],
            assignments: [
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
                  {:gt, [signature: {[:integer, :integer], :boolean}],
                   [
                     {:var, [signature: {[:name], :integer}], [[:int_list, 2]]},
                     32
                   ]}
              }
            ],
            assignments: [
              %{target: :enum_string, expression: "v1"},
              %{target: :int_list, expression: [1, 2, 3]}
            ]
          }
        ]
      }
    ]
  }

  @blueprint %{
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

  @blueprint %{
    name: :ruleset0,
    variables: %{
      birthdate: %{
        type: :date,
        input: true
      },
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
        type: :map,
        output: true,
        children: %{
          moderna: %{
            type: :map,
            output: true,
            children: %{
              compatible: %{type: :boolean, output: true},
              priority: %{type: :integer, output: true}
            }
          },
          pfizer: %{
            type: :map,
            output: true,
            children: %{
              compatible: %{type: :boolean, output: true},
              priority: %{type: :integer, output: true}
            }
          }
        }
      },
      age: %{
        type: :integer,
        output: true
      },
      eligible: %{
        type: :boolean
      },
      flags: %{
        type: :map,
        output: true,
        children: %{
          need_determine_pregnant: %{type: :boolean, output: true},
          immuno_need_recommendation: %{type: :boolean, output: true},
          infection: %{type: :boolean, output: true}
        }
      },
      injection_sequence: %{
        type: "map[]",
        output: true,
        children: %{
          vaccine: %{type: :string, output: true},
          delay_min: %{type: :integer, output: true},
          delay_max: %{type: :integer, output: true},
          reference_date: %{type: :date, output: true},
          next_injection: %{
            type: "map",
            output: true,
            children: %{
              vaccine: %{type: :string, output: true},
              delay_min: %{type: :integer, output: true},
              delay_max: %{type: :integer, output: true}
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
            assignments: [
              %{
                target: :age,
                expression: quote(do: age(@birthdate))
              }
            ]
          }
        ]
      },
      %{
        branches: [
          %{
            conditions: [
              %{expression: quote(do: lt(@age, 12))}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :compatible],
                description: "<12",
                expression: false
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :compatible],
                description: "<12",
                expression: false
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@immuno))},
              %{expression: quote(do: is_false(@immuno_recommended))}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :compatible],
                description: "immuno not recommended",
                expression: false
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :compatible],
                description: "immuno not recommended",
                expression: false
              }
            ]
          },
          %{
            conditions: [],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :compatible],
                description: "other",
                expression: true
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :compatible],
                description: "other",
                expression: true
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
                  quote(
                    do:
                      is_false(
                        var([:vaccine_compatibilities, :moderna, :compatible])
                      )
                  )
              },
              %{
                expression:
                  quote(
                    do:
                      is_false(
                        var([:vaccine_compatibilities, :pfizer, :compatible])
                      )
                  )
              }
            ],
            assignments: [
              %{
                target: :eligible,
                expression: false
              }
            ]
          },
          %{
            conditions: [],
            assignments: [
              %{
                target: :eligible,
                expression: true
              }
            ]
          }
        ]
      },
      %{
        branches: [
          %{
            conditions: [
              %{expression: quote(do: gt(@age, 75))}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "> 75 years",
                expression: 1
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "> 75 years",
                expression: 1
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@high_risk))}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "high risk",
                expression: 1
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "high risk",
                expression: 1
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@immuno))},
              %{expression: quote(do: is_true(@immuno_recommended))}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "immuno",
                expression: 1
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "immuno",
                expression: 1
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: gt(@age, 65))}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "> 65",
                expression: 2
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "> 65",
                expression: 2
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: gt(@age, 60))}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "> 60",
                expression: 3
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "> 60",
                expression: 3
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@healthcare_worker))}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "healthcare worker",
                expression: 4
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "healthcare worker",
                expression: 4
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@high_risk_contact))}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "high risk contact",
                expression: 5
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "high risk contact",
                expression: 5
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@community_facility))}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "community facility",
                expression: 6
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "community facility",
                expression: 6
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@immuno))},
              %{expression: quote(do: is_false(@immuno_recommended))}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "immuno not recommended",
                expression: -1
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "immuno not recommended",
                expression: -1
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: lt(@age, 12))}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "< 12",
                expression: -1
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "< 12",
                expression: -1
              }
            ]
          },
          %{
            conditions: [],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "other",
                expression: 7
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "other",
                expression: 7
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
                expression: quote(do: eq(@gender, "f"))
              }
            ],
            assignments: [
              %{
                target: [:flags, :need_determine_pregnant],
                expression: true
              }
            ]
          }
        ]
      },
      %{
        branches: [
          %{
            conditions: [
              %{expression: quote(do: is_true(@immuno))},
              %{expression: quote(do: is_true(@immuno_discussed))}
            ],
            assignments: [
              %{
                target: [:flags, :immuno_need_recommendation],
                expression: true
              }
            ]
          }
        ]
      },
      %{
        branches: [
          %{
            conditions: [
              %{expression: quote(do: is_not_nil(@infection_date))},
              %{expression: quote(do: is_true(@eligible))}
            ],
            assignments: [
              %{
                target: [:flags, :infection],
                expression: true
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
                  quote(
                    do:
                      is_true(
                        var([:vaccine_compatibilities, :moderna, :compatible])
                      )
                  )
              },
              %{
                expression: quote(do: is_not_nil(@infection_date))
              }
            ],
            assignments: [
              %{
                target: [:injection_sequence, 0, :vaccine],
                expression: "moderna"
              },
              %{
                target: [:injection_sequence, 0, :delay_min],
                expression: 28
              },
              %{
                target: [:injection_sequence, 0, :reference_date],
                expression: quote(do: @infection_date)
              }
            ]
          },
          %{
            conditions: [
              %{
                expression:
                  quote(
                    do:
                      is_true(
                        var([:vaccine_compatibilities, :moderna, :compatible])
                      )
                  )
              }
            ],
            assignments: [
              %{
                target: [:injection_sequence, 0, :vaccine],
                expression: "moderna"
              },
              %{
                target: [:injection_sequence, 0, :delay_min],
                expression: 0
              },
              %{
                target: [:injection_sequence, 0, :reference_date],
                expression: quote(do: now())
              },
              %{
                target: [:injection_sequence, 0, :next_injection, :vaccine],
                expression: "moderna"
              },
              %{
                target: [:injection_sequence, 0, :next_injection, :delay_min],
                expression: 28
              },
              %{
                target: [:injection_sequence, 0, :next_injection, :delay_max],
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
                  quote(
                    do:
                      is_true(
                        var([:vaccine_compatibilities, :pfizer, :compatible])
                      )
                  )
              },
              %{
                expression: quote(do: is_not_nil(@infection_date))
              }
            ],
            assignments: [
              %{
                target: [:injection_sequence, 1, :vaccine],
                expression: "pfizer"
              },
              %{
                target: [:injection_sequence, 1, :delay_min],
                expression: 28
              },
              %{
                target: [:injection_sequence, 1, :reference_date],
                expression: quote(do: @infection_date)
              }
            ]
          },
          %{
            conditions: [
              %{
                expression:
                  quote(
                    do:
                      is_true(
                        var([:vaccine_compatibilities, :pfizer, :compatible])
                      )
                  )
              }
            ],
            assignments: [
              %{
                target: [:injection_sequence, 1, :vaccine],
                expression: "pfizer"
              },
              %{
                target: [:injection_sequence, 1, :delay_min],
                expression: 0
              },
              %{
                target: [:injection_sequence, 1, :reference_date],
                expression: quote(do: now())
              },
              %{
                target: [:injection_sequence, 1, :next_injection, :vaccine],
                expression: "pfizer"
              },
              %{
                target: [:injection_sequence, 1, :next_injection, :delay_min],
                expression: 28
              },
              %{
                target: [:injection_sequence, 1, :next_injection, :delay_max],
                expression: 35
              }
            ]
          }
        ]
      }
    ]
  }

  @blueprint %{
    name: :hash0_test,
    variables: [
      %{name: :aint, type: :integer, input: true, output: false, default: 0}
    ],
    deductions: []
  }

  @blueprint %{
    name: :hash1_test,
    variables: [
      %{name: :aint, type: :integer, input: true, output: false, default: 0},
      %{name: :bint, type: :integer, input: false, output: false, default: 0}
    ],
    deductions: []
  }

  @blueprint %{
    name: :hash2_test,
    variables: [
      %{name: :bint, type: :integer, input: false, output: false, default: 0},
      %{name: :aint, type: :integer, input: true, output: false, default: 0}
    ],
    deductions: []
  }

  @blueprint %{
    name: :hash3_test,
    variables: [
      %{name: :bint, type: :integer, input: true, output: false, default: 0},
      %{name: :aint, type: :integer, input: true, output: false, default: 0}
    ],
    deductions: []
  }

  def blueprints() do
    @blueprint
    |> Enum.map(fn b ->
      {b.name, b |> smap()}
    end)
    |> Map.new()
  end
end
