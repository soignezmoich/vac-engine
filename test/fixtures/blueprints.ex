defmodule Fixtures.Blueprints do
  import Fixtures.Helpers
  Module.register_attribute(__MODULE__, :blueprint, accumulate: true)

  @blueprint %{
    name: :simple_test,
    variables: %{
      aint: %{type: :integer, mapping: :in_required, default: 0},
      bint: %{type: :integer, mapping: :inout_required, default: 0},
      cint: %{type: :integer, mapping: :inout_required, default: 0}
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
        mapping: :in_required,
        validators: [
          %{expression: quote(do: contains(["v1", "v2"], @self))}
        ]
      },
      obj_list: %{
        type: "map[]",
        mapping: :in_required,
        children: %{
          child_int: %{type: :integer, mapping: :in_required},
          child_object: %{
            type: :map,
            mapping: :in_required,
            children: %{
              grand_child_int: %{type: :integer, mapping: :in_required}
            }
          }
        }
      },
      int_list: %{
        type: "integer[]",
        mapping: :inout_required
      },
      dnest: %{
        type: "map[]",
        mapping: :out,
        children: %{
          dnest2: %{
            type: "map[]",
            mapping: :out,
            children: %{
              dnest3: %{type: :string, mapping: :out}
            }
          }
        }
      },
      map_list: %{
        type: "map[]",
        mapping: :out,
        children: %{
          child_string: %{type: :string, mapping: :out},
          child_int: %{type: :integer, mapping: :out},
          child_object: %{
            type: :map,
            mapping: :out,
            children: %{
              grand_child_int: %{type: :integer, mapping: :out},
              grand_child_map: %{
                type: :map,
                mapping: :out,
                children: %{
                  grand_grand_child_ints: %{type: "integer[]", mapping: :out}
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
                  :grand_grand_child_ints
                ],
                expression: [1, 2, 3]
              },
              %{
                target: [
                  :map_list,
                  1,
                  :child_object,
                  :grand_child_map,
                  :grand_grand_child_ints,
                  8
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
        mapping: :inout_required,
        children: %{
          name: %{type: :string, mapping: :in_required},
          nested: %{
            type: "map[]",
            mapping: :inout_required,
            children: %{
              nested: %{type: "integer[]", mapping: :inout_required}
            }
          }
        }
      },
      int: %{
        type: "integer",
        mapping: :in_required
      },
      str: %{
        type: "string",
        mapping: :in_required
      },
      num: %{
        type: "number",
        mapping: :in_required
      },
      ignore: %{
        type: "string",
        mapping: :out
      },
      map: %{
        type: :map,
        mapping: :in_required,
        children: %{
          nlist: %{type: "integer[]", mapping: :in_required},
          nmap: %{
            type: :map,
            mapping: :in_required,
            children: %{
              name: %{type: :string, mapping: :in_required}
            }
          },
          nlist2: %{
            type: "map[]",
            mapping: :in_required,
            children: %{
              nested: %{type: :integer, mapping: :in_required}
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
        mapping: :in_required
      },
      gender: %{
        type: :string,
        mapping: :in_required
      },
      pregnant: %{
        type: :string,
        mapping: :in_required
      },
      high_risk: %{
        type: :boolean,
        mapping: :in_required
      },
      immuno: %{
        type: :boolean,
        mapping: :in_required
      },
      immuno_discussed: %{
        type: :boolean,
        mapping: :in_required
      },
      immuno_recommended: %{
        type: :boolean,
        mapping: :in_required
      },
      healthcare_worker: %{
        type: :boolean,
        mapping: :in_required
      },
      high_risk_contact: %{
        type: :boolean,
        mapping: :in_required
      },
      immuno_contact: %{
        type: :boolean,
        mapping: :in_required
      },
      community_facility: %{
        type: :boolean,
        mapping: :in_required
      },
      infection_date: %{
        type: :date,
        mapping: :in_required
      },
      vaccine_allergy: %{
        type: :boolean,
        mapping: :in_required
      },
      vaccine_compatibilities: %{
        type: :map,
        mapping: :out,
        children: %{
          moderna: %{
            type: :map,
            mapping: :out,
            children: %{
              compatible: %{type: :boolean, mapping: :out},
              priority: %{type: :integer, mapping: :out}
            }
          },
          pfizer: %{
            type: :map,
            mapping: :out,
            children: %{
              compatible: %{type: :boolean, mapping: :out},
              priority: %{type: :integer, mapping: :out}
            }
          }
        }
      },
      age: %{
        type: :integer,
        mapping: :out
      },
      eligible: %{
        type: :boolean
      },
      flags: %{
        type: :map,
        mapping: :out,
        children: %{
          need_determine_pregnant: %{type: :boolean, mapping: :out},
          immuno_need_recommendation: %{type: :boolean, mapping: :out},
          infection: %{type: :boolean, mapping: :out}
        }
      },
      injection_sequence: %{
        type: "map[]",
        mapping: :out,
        children: %{
          vaccine: %{type: :string, mapping: :out},
          delay_min: %{type: :integer, mapping: :out},
          delay_max: %{type: :integer, mapping: :out},
          reference_date: %{type: :date, mapping: :out},
          next_injection: %{
            type: "map",
            mapping: :out,
            children: %{
              vaccine: %{type: :string, mapping: :out},
              delay_min: %{type: :integer, mapping: :out},
              delay_max: %{type: :integer, mapping: :out}
            }
          }
        }
      }
    },
    deductions: [
      %{
        columns: [
          %{description: "Age", variable: :birthdate, type: "assignment"}
        ],
        branches: [
          %{
            conditions: [],
            assignments: [
              %{
                target: :age,
                expression: quote(do: age(@birthdate)),
                column: 0
              }
            ]
          }
        ]
      },
      %{
        columns: [
          %{description: "Age", variable: :age},
          %{description: "Immuno", variable: :immuno},
          %{description: "Immuno recommended", variable: :immuno_recommended},
          %{
            description: "Moderna compatibility",
            variable: [:vaccine_compatibilities, :moderna, :compatible],
            type: "assignment"
          },
          %{
            description: "Pfizer compatibility",
            variable: [:vaccine_compatibilities, :pfizer, :compatible],
            type: "assignment"
          }
        ],
        branches: [
          %{
            conditions: [
              %{expression: quote(do: lt(@age, 12)), column: 0}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :compatible],
                description: "<12",
                column: 3,
                expression: false
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :compatible],
                description: "<12",
                column: 4,
                expression: false
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@immuno)), column: 1},
              %{expression: quote(do: is_false(@immuno_recommended)), column: 2}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :compatible],
                description: "immuno not recommended",
                column: 3,
                expression: false
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :compatible],
                description: "immuno not recommended",
                column: 4,
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
                column: 3,
                expression: true
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :compatible],
                description: "other",
                column: 4,
                expression: true
              }
            ]
          }
        ]
      },
      %{
        columns: [
          %{
            description: "Moderna compatibility",
            variable: [:vaccine_compatibilities, :moderna, :compatible]
          },
          %{
            description: "Pfizer compatibility",
            variable: [:vaccine_compatibilities, :pfizer, :compatible]
          },
          %{description: "Eligible", variable: :eligible, type: "assignment"}
        ],
        branches: [
          %{
            conditions: [
              %{
                column: 0,
                expression:
                  quote(
                    do:
                      is_false(
                        var([:vaccine_compatibilities, :moderna, :compatible])
                      )
                  )
              },
              %{
                column: 1,
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
                column: 2,
                target: :eligible,
                expression: false
              }
            ]
          },
          %{
            conditions: [],
            assignments: [
              %{
                column: 2,
                target: :eligible,
                expression: true
              }
            ]
          }
        ]
      },
      %{
        columns: [
          %{description: "Age", variable: :age},
          %{description: "High risk", variable: :high_risk},
          %{description: "Immuno", variable: :immuno},
          %{description: "Immuno recommended", variable: :immuno_recommended},
          %{description: "Healthcare worker", variable: :healthcare_worker},
          %{description: "High risk contact", variable: :high_risk_contact},
          %{description: "Community facility", variable: :community_facility},
          %{
            description: "Moderna priority",
            variable: [:vaccine_compatibilities, :moderna, :priority],
            type: "assignment"
          },
          %{
            description: "Pfizer priority",
            variable: [:vaccine_compatibilities, :pfizer, :priority],
            type: "assignment"
          }
        ],
        branches: [
          %{
            conditions: [
              %{expression: quote(do: gt(@age, 75)), column: 0}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "> 75 years",
                column: 7,
                expression: 1
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "> 75 years",
                column: 8,
                expression: 1
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@high_risk)), column: 1}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "high risk",
                column: 7,
                expression: 1
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "high risk",
                column: 8,
                expression: 1
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@immuno)), column: 2},
              %{expression: quote(do: is_true(@immuno_recommended)), column: 3}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "immuno",
                column: 7,
                expression: 1
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "immuno",
                column: 8,
                expression: 1
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: gt(@age, 65)), column: 0}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "> 65",
                column: 7,
                expression: 2
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "> 65",
                column: 8,
                expression: 2
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: gt(@age, 60)), column: 0}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "> 60",
                column: 7,
                expression: 3
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "> 60",
                column: 8,
                expression: 3
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@healthcare_worker)), column: 4}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "healthcare worker",
                column: 7,
                expression: 4
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "healthcare worker",
                column: 8,
                expression: 4
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@high_risk_contact)), column: 5}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "high risk contact",
                column: 7,
                expression: 5
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "high risk contact",
                column: 8,
                expression: 5
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@community_facility)), column: 6}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "community facility",
                column: 7,
                expression: 6
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "community facility",
                column: 8,
                expression: 6
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: is_true(@immuno)), column: 2},
              %{expression: quote(do: is_false(@immuno_recommended)), column: 3}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "immuno not recommended",
                column: 7,
                expression: -1
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "immuno not recommended",
                column: 7,
                expression: -1
              }
            ]
          },
          %{
            conditions: [
              %{expression: quote(do: lt(@age, 12)), column: 0}
            ],
            assignments: [
              %{
                target: [:vaccine_compatibilities, :moderna, :priority],
                description: "< 12",
                column: 7,
                expression: -1
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "< 12",
                column: 8,
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
                column: 7,
                expression: 7
              },
              %{
                target: [:vaccine_compatibilities, :pfizer, :priority],
                description: "other",
                column: 8,
                expression: 7
              }
            ]
          }
        ]
      },
      %{
        columns: [
          %{
            description: "Gender",
            variable: :gender
          },
          %{
            description: "Pregnant",
            variable: [:flags, :need_determine_pregnant],
            type: "assignment"
          }
        ],
        branches: [
          %{
            conditions: [
              %{
                expression: quote(do: eq(@gender, "f")),
                column: 0
              }
            ],
            assignments: [
              %{
                column: 1,
                target: [:flags, :need_determine_pregnant],
                expression: true
              }
            ]
          }
        ]
      },
      %{
        columns: [
          %{
            description: "Immuno",
            variable: :immuno
          },
          %{
            description: "Immuno  discussed",
            variable: :immuno_discussed
          },
          %{
            description: "Immuno need recommendation",
            variable: [:flags, :immuno_need_recommendation],
            type: "assignment"
          }
        ],
        branches: [
          %{
            conditions: [
              %{expression: quote(do: is_true(@immuno)), column: 0},
              %{expression: quote(do: is_true(@immuno_discussed)), column: 1}
            ],
            assignments: [
              %{
                column: 2,
                target: [:flags, :immuno_need_recommendation],
                expression: true
              }
            ]
          }
        ]
      },
      %{
        columns: [
          %{
            description: "Infection date",
            variable: :infection_date
          },
          %{
            description: "Eligible",
            variable: :eligible
          },
          %{
            description: "Infection",
            variable: [:flags, :infection],
            type: "assignment"
          }
        ],
        branches: [
          %{
            conditions: [
              %{expression: quote(do: is_not_nil(@infection_date)), column: 0},
              %{expression: quote(do: is_true(@eligible)), column: 1}
            ],
            assignments: [
              %{
                target: [:flags, :infection],
                column: 2,
                expression: true
              }
            ]
          }
        ]
      },
      %{
        columns: [
          %{
            description: "Moderna compatible",
            variable: [:vaccine_compatibilities, :moderna, :compatible]
          },
          %{
            description: "Infection date",
            variable: :infection_date
          },
          %{
            description: "Vaccine",
            variable: [:injection_sequence, 0, :vaccine],
            type: "assignment"
          },
          %{
            description: "Delay min",
            variable: [:injection_sequence, 0, :delay_min],
            type: "assignment"
          },
          %{
            description: "Delay max",
            variable: [:injection_sequence, 0, :delay_max],
            type: "assignment"
          },
          %{
            description: "Reference date",
            variable: [:injection_sequence, 0, :reference_date],
            type: "assignment"
          },
          %{
            description: "Next injection Vaccine",
            variable: [:injection_sequence, 0, :next_injection, :vaccine],
            type: "assignment"
          },
          %{
            description: "Next injection Delay min",
            variable: [:injection_sequence, 0, :next_injection, :delay_min],
            type: "assignment"
          },
          %{
            description: "Next injection Delay max",
            variable: [:injection_sequence, 0, :next_injection, :delay_max],
            type: "assignment"
          },
          %{
            description: "Next injection Reference date",
            variable: [:injection_sequence, 0, :next_injection, :reference_date],
            type: "assignment"
          }
        ],
        branches: [
          %{
            conditions: [
              %{
                column: 0,
                expression:
                  quote(
                    do:
                      is_true(
                        var([:vaccine_compatibilities, :moderna, :compatible])
                      )
                  )
              },
              %{
                column: 1,
                expression: quote(do: is_not_nil(@infection_date))
              }
            ],
            assignments: [
              %{
                column: 2,
                target: [:injection_sequence, 0, :vaccine],
                expression: "moderna"
              },
              %{
                column: 3,
                target: [:injection_sequence, 0, :delay_min],
                expression: 28
              },
              %{
                column: 4,
                target: [:injection_sequence, 0, :reference_date],
                expression: quote(do: @infection_date)
              }
            ]
          },
          %{
            conditions: [
              %{
                column: 0,
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
                column: 2,
                expression: "moderna"
              },
              %{
                target: [:injection_sequence, 0, :delay_min],
                column: 3,
                expression: 0
              },
              %{
                target: [:injection_sequence, 0, :reference_date],
                column: 5,
                expression: quote(do: now())
              },
              %{
                target: [:injection_sequence, 0, :next_injection, :vaccine],
                column: 6,
                expression: "moderna"
              },
              %{
                target: [:injection_sequence, 0, :next_injection, :delay_min],
                column: 7,
                expression: 28
              },
              %{
                target: [:injection_sequence, 0, :next_injection, :delay_max],
                column: 8,
                expression: 35
              }
            ]
          }
        ]
      },
      %{
        columns: [
          %{
            description: "Pfizer compatible",
            variable: [:vaccine_compatibilities, :pfizer, :compatible]
          },
          %{
            description: "Infection date",
            variable: :infection_date
          },
          %{
            description: "Vaccine",
            variable: [:injection_sequence, 1, :vaccine],
            type: "assignment"
          },
          %{
            description: "Delay min",
            variable: [:injection_sequence, 1, :delay_min],
            type: "assignment"
          },
          %{
            description: "Delay max",
            variable: [:injection_sequence, 1, :delay_max],
            type: "assignment"
          },
          %{
            description: "Reference date",
            variable: [:injection_sequence, 1, :reference_date],
            type: "assignment"
          },
          %{
            description: "Next injection Vaccine",
            variable: [:injection_sequence, 1, :next_injection, :vaccine],
            type: "assignment"
          },
          %{
            description: "Next injection Delay min",
            variable: [:injection_sequence, 1, :next_injection, :delay_min],
            type: "assignment"
          },
          %{
            description: "Next injection Delay max",
            variable: [:injection_sequence, 1, :next_injection, :delay_max],
            type: "assignment"
          },
          %{
            description: "Next injection Reference date",
            variable: [:injection_sequence, 1, :next_injection, :reference_date],
            type: "assignment"
          }
        ],
        branches: [
          %{
            conditions: [
              %{
                column: 0,
                expression:
                  quote(
                    do:
                      is_true(
                        var([:vaccine_compatibilities, :pfizer, :compatible])
                      )
                  )
              },
              %{
                column: 1,
                expression: quote(do: is_not_nil(@infection_date))
              }
            ],
            assignments: [
              %{
                column: 2,
                target: [:injection_sequence, 1, :vaccine],
                expression: "pfizer"
              },
              %{
                column: 3,
                target: [:injection_sequence, 1, :delay_min],
                expression: 28
              },
              %{
                column: 5,
                target: [:injection_sequence, 1, :reference_date],
                expression: quote(do: @infection_date)
              }
            ]
          },
          %{
            conditions: [
              %{
                column: 0,
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
                column: 2,
                target: [:injection_sequence, 1, :vaccine],
                expression: "pfizer"
              },
              %{
                column: 3,
                target: [:injection_sequence, 1, :delay_min],
                expression: 0
              },
              %{
                column: 5,
                target: [:injection_sequence, 1, :reference_date],
                expression: quote(do: now())
              },
              %{
                column: 6,
                target: [:injection_sequence, 1, :next_injection, :vaccine],
                expression: "pfizer"
              },
              %{
                column: 7,
                target: [:injection_sequence, 1, :next_injection, :delay_min],
                expression: 28
              },
              %{
                column: 8,
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
      %{name: :aint, type: :integer, mapping: :in_required, default: 0}
    ],
    deductions: []
  }

  @blueprint %{
    name: :hash1_test,
    variables: [
      %{name: :aint, type: :integer, mapping: :in_required, default: 0},
      %{name: :bint, type: :integer, mapping: :none, default: 0}
    ],
    deductions: []
  }

  @blueprint %{
    name: :hash2_test,
    variables: [
      %{name: :bint, type: :integer, mapping: :none, default: 0},
      %{name: :aint, type: :integer, mapping: :in_required, default: 0}
    ],
    deductions: []
  }

  @blueprint %{
    name: :hash3_test,
    variables: [
      %{name: :bint, type: :integer, mapping: :in_required, default: 0},
      %{name: :aint, type: :integer, mapping: :in_required, default: 0}
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
