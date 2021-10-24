defmodule Fixtures.Blueprints do
  import Fixtures.Helpers
  use Fixtures.Helpers.Blueprints

  blueprint(:simple_test) do
    %{
      variables: %{
        aint: %{
          type: :integer,
          mapping: :in_required,
          default: quote(do: now())
        },
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
  end

  blueprint(:sig_test) do
    %{
      variables: %{
        age: %{type: :integer, mapping: :in_optional, default: 0}
      },
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
  end

  blueprint(:nested_test) do
    %{
      variables: %{
        enum_string: %{
          type: "string",
          mapping: :in_required,
          enum: ["v1", "v2"]
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
          type: "map",
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
                %{expression: quote(do: eq(@enum_string, "v1"))},
                %{
                  expression:
                    quote(
                      do:
                        eq(
                          var([:obj_list, 0, :child_object, :grand_child_int]),
                          98
                        )
                    )
                }
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
                %{
                  target: [:dnest, :dnest2, 4, :dnest3],
                  expression: "nested"
                },
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
                       {:var, [signature: {[:name], :integer}],
                        [[:int_list, 2]]},
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
  end

  blueprint(:map_test) do
    %{
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
  end

  blueprint(:ruleset0) do
    %{
      variables: %{
        birthdate: %{
          type: :date,
          mapping: :in_required
        },
        gender: %{
          type: :string,
          mapping: :in_required,
          enum: ["m", "f", "other"]
        },
        pregnant: %{
          type: :string,
          mapping: :in_required,
          enum: ["yes", "no", "unknown"]
        },
        high_risk: %{
          type: :boolean,
          mapping: :in_required
        },
        extremely_vulnerable: %{
          type: :boolean,
          mapping: :in_optional
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
          mapping: :in_optional
        },
        vaccine_allergy: %{
          type: :boolean,
          mapping: :in_required
        },
        rejects_mrna: %{
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
            },
            janssen: %{
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
          type: :integer
        },
        eligible: %{
          type: :boolean
        },
        injection_sequence: %{
          type: :map,
          mapping: :out,
          children: %{
            moderna: %{
              type: :map,
              mapping: :out,
              children: %{
                vaccine: %{
                  type: :string,
                  mapping: :out,
                  enum: ["moderna", "pfizer", "janssen"]
                },
                delay_min: %{type: :integer, mapping: :out},
                delay_max: %{type: :integer, mapping: :out},
                reference_date: %{type: :date, mapping: :out},
                dose_type: %{type: :string, mapping: :out},
                next_injections: %{
                  type: :map,
                  mapping: :out,
                  children: %{
                    moderna: %{
                      type: :map,
                      mapping: :out,
                      children: %{
                        vaccine: %{
                          type: :string,
                          mapping: :out,
                          enum: ["moderna", "pfizer", "janssen"]
                        },
                        delay_min: %{type: :integer, mapping: :out},
                        delay_max: %{type: :integer, mapping: :out},
                        reference_date: %{type: :date, mapping: :out},
                        dose_type: %{type: :string, mapping: :out}
                      }
                    }
                  }
                }
              }
            },
            pfizer: %{
              type: :map,
              mapping: :out,
              children: %{
                vaccine: %{
                  type: :string,
                  mapping: :out,
                  enum: ["moderna", "pfizer", "janssen"]
                },
                delay_min: %{type: :integer, mapping: :out},
                delay_max: %{type: :integer, mapping: :out},
                reference_date: %{type: :date, mapping: :out},
                dose_type: %{type: :string, mapping: :out},
                next_injections: %{
                  type: :map,
                  mapping: :out,
                  children: %{
                    pfizer: %{
                      type: :map,
                      mapping: :out,
                      children: %{
                        vaccine: %{
                          type: :string,
                          mapping: :out,
                          enum: ["moderna", "pfizer", "janssen"]
                        },
                        delay_min: %{type: :integer, mapping: :out},
                        delay_max: %{type: :integer, mapping: :out},
                        reference_date: %{type: :date, mapping: :out},
                        dose_type: %{type: :string, mapping: :out}
                      }
                    }
                  }
                }
              }
            },
            janssen: %{
              type: :map,
              mapping: :out,
              children: %{
                vaccine: %{
                  type: :string,
                  mapping: :out,
                  enum: ["moderna", "pfizer", "janssen"]
                },
                delay_min: %{type: :integer, mapping: :out},
                delay_max: %{type: :integer, mapping: :out},
                reference_date: %{type: :date, mapping: :out},
                dose_type: %{type: :string, mapping: :out}
              }
            }
          }
        },
        registrable_if_dose_within: %{
          type: :integer,
          mapping: :out
        },
        flags: %{
          type: :map,
          mapping: :out,
          children: %{
            immuno_need_recommendation: %{type: :boolean, mapping: :out},
            immuno_not_recommended: %{type: :boolean, mapping: :out},
            under_12: %{type: :boolean, mapping: :out},
            janssen_pregnant: %{type: :boolean, mapping: :out},
            janssen_immuno: %{type: :boolean, mapping: :out},
            janssen_under_18: %{type: :boolean, mapping: :out}
          }
        }
      },
      deductions: [
        %{
          columns: [
            %{type: "assignment", variable: :age}
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
            %{type: "assignment", variable: :registrable_if_dose_within}
          ],
          branches: [
            %{
              assignments: [
                %{
                  target: :registrable_if_dose_within,
                  expression: 30,
                  column: 0
                }
              ]
            }
          ]
        },
        %{
          description: "MODERNA & PFIZER COMPATIBILITY",
          columns: [
            %{variable: :rejects_mrna},
            %{variable: :immuno},
            %{variable: :immuno_recommended},
            %{variable: :age},
            %{
              type: "assignment",
              variable: [:vaccine_compatibilities, :moderna, :compatible]
            },
            %{
              type: "assignment",
              variable: [:vaccine_compatibilities, :pfizer, :compatible]
            }
          ],
          branches: [
            %{
              conditions: [
                %{expression: quote(do: is_true(@rejects_mrna)), column: 0}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :compatible],
                  description: "rejects_mrna",
                  column: 4,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "rejects_mrna",
                  column: 5,
                  expression: false
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: is_true(@immuno)), column: 1},
                %{
                  expression: quote(do: is_false(@immuno_recommended)),
                  column: 2
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :compatible],
                  description: "immuno_no_recommendation",
                  column: 4,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "immuno_no_recommendation",
                  column: 5,
                  expression: false
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: lt(@age, 12)), column: 3}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :compatible],
                  description: "younger_than_12",
                  column: 4,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "younger_than_12",
                  column: 5,
                  expression: false
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: lt(@age, 16)), column: 3}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :compatible],
                  description: "younger_than_16",
                  column: 4,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "other",
                  column: 5,
                  expression: true
                }
              ]
            },
            %{
              conditions: [],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :compatible],
                  description: "other",
                  column: 4,
                  expression: true
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "other",
                  column: 5,
                  expression: true
                }
              ]
            }
          ]
        },
        %{
          description: "JANSSEN COMPATIBILITY",
          columns: [
            %{variable: :rejects_mrna},
            %{variable: :immuno},
            %{variable: :pregnant},
            %{variable: :age},
            %{
              type: "assignment",
              variable: [:vaccine_compatibilities, :janssen, :compatible]
            }
          ],
          branches: [
            %{
              conditions: [
                %{expression: quote(do: is_false(@rejects_mrna)), column: 0}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "accepts_mrna",
                  column: 4,
                  expression: false
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: is_true(@immuno)), column: 1}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "immuno",
                  column: 4,
                  expression: false
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: neq(@pregnant, "no")), column: 2}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "pregnant",
                  column: 4,
                  expression: false
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: lt(@age, 18)), column: 3}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "younger_than_18",
                  column: 4,
                  expression: false
                }
              ]
            },
            %{
              conditions: [],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "rejects_mrna_vaccines",
                  column: 4,
                  expression: true
                }
              ]
            }
          ]
        },
        %{
          description: "ELIGIBILITY",
          columns: [
            %{variable: [:vaccine_compatibilities, :moderna, :compatible]},
            %{variable: [:vaccine_compatibilities, :pfizer, :compatible]},
            %{variable: [:vaccine_compatibilities, :janssen, :compatible]},
            %{type: "assignment", variable: :eligible}
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
                },
                %{
                  column: 2,
                  expression:
                    quote(
                      do:
                        is_false(
                          var([:vaccine_compatibilities, :janssen, :compatible])
                        )
                    )
                }
              ],
              assignments: [
                %{
                  column: 3,
                  target: :eligible,
                  expression: false
                }
              ]
            },
            %{
              conditions: [],
              assignments: [
                %{
                  column: 3,
                  target: :eligible,
                  expression: true
                }
              ]
            }
          ]
        },
        %{
          description: "MODERNA PRIORITY",
          columns: [
            %{variable: [:vaccine_compatibilities, :moderna, :compatible]},
            %{variable: :immuno_recommended},
            %{variable: :extremely_vulnerable},
            %{variable: :age},
            %{
              type: "assignment",
              variable: [:vaccine_compatibilities, :moderna, :priority]
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
                        is_false(
                          var([:vaccine_compatibilities, :moderna, :compatible])
                        )
                    )
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :priority],
                  description: "not_moderna_compatible",
                  column: 4,
                  expression: -1
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: lt(@age, 18)), column: 3}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :priority],
                  description: "younger_than_18",
                  column: 4,
                  expression: 1
                }
              ]
            },
            %{
              conditions: [
                %{
                  expression: quote(do: is_true(@immuno_recommended)),
                  column: 1
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :priority],
                  description: "immuno",
                  column: 4,
                  expression: 2
                }
              ]
            },
            %{
              conditions: [
                %{
                  expression: quote(do: is_true(@extremely_vulnerable)),
                  column: 2
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :priority],
                  description: "extremely_vulnerable",
                  column: 4,
                  expression: 2
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 65)), column: 3}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :priority],
                  description: "older_than_65",
                  column: 4,
                  expression: 2
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 50)), column: 3}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :priority],
                  description: "older_than_60",
                  column: 4,
                  expression: 3
                }
              ]
            },
            %{
              conditions: [],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :priority],
                  description: "other",
                  column: 4,
                  expression: 4
                }
              ]
            }
          ]
        },
        %{
          description: "PFIZER PRIORITY",
          columns: [
            %{variable: [:vaccine_compatibilities, :pfizer, :compatible]},
            %{variable: :immuno_recommended},
            %{variable: :extremely_vulnerable},
            %{variable: :age},
            %{
              type: "assignment",
              variable: [:vaccine_compatibilities, :pfizer, :priority]
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
                        is_false(
                          var([:vaccine_compatibilities, :pfizer, :compatible])
                        )
                    )
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "not_moderna_compatible",
                  column: 4,
                  expression: -1
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: lt(@age, 18)), column: 3}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "younger_than_18",
                  column: 4,
                  expression: 1
                }
              ]
            },
            %{
              conditions: [
                %{
                  expression: quote(do: is_true(@immuno_recommended)),
                  column: 1
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "immuno",
                  column: 4,
                  expression: 1
                }
              ]
            },
            %{
              conditions: [
                %{
                  expression: quote(do: is_true(@extremely_vulnerable)),
                  column: 2
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "extremely_vulnerable",
                  column: 4,
                  expression: 2
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 65)), column: 3}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "older_than_65",
                  column: 4,
                  expression: 2
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 50)), column: 3}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "older_than_60",
                  column: 4,
                  expression: 3
                }
              ]
            },
            %{
              conditions: [],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "other",
                  column: 4,
                  expression: 4
                }
              ]
            }
          ]
        },
        %{
          description: "JANSSEN PRIORITY",
          columns: [
            %{variable: [:vaccine_compatibilities, :janssen, :compatible]},
            %{
              type: "assignment",
              variable: [:vaccine_compatibilities, :janssen, :priority]
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
                        is_false(
                          var([:vaccine_compatibilities, :janssen, :compatible])
                        )
                    )
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :priority],
                  description: "not_janssen_compatible",
                  column: 1,
                  expression: -1
                }
              ]
            },
            %{
              conditions: [],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :priority],
                  description: "other",
                  column: 1,
                  expression: 1
                }
              ]
            }
          ]
        },
        %{
          description: "MODERNA SEQUENCE START",
          columns: [
            %{variable: [:vaccine_compatibilities, :moderna, :compatible]},
            %{variable: :infection_date},
            %{
              type: "assignment",
              variable: [:injection_sequence, :moderna, :vaccine]
            },
            %{
              type: "assignment",
              variable: [:injection_sequence, :moderna, :delay_min]
            },
            %{
              type: "assignment",
              variable: [:injection_sequence, :moderna, :delay_max]
            },
            %{
              type: "assignment",
              variable: [:injection_sequence, :moderna, :reference_date]
            },
            %{
              type: "assignment",
              variable: [:injection_sequence, :moderna, :dose_type]
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
                  target: [:injection_sequence, :moderna, :vaccine],
                  expression: "moderna"
                },
                %{
                  column: 3,
                  target: [:injection_sequence, :moderna, :delay_min],
                  expression: 28
                },
                %{
                  column: 5,
                  target: [:injection_sequence, :moderna, :reference_date],
                  expression: quote(do: @infection_date)
                },
                %{
                  column: 6,
                  target: [:injection_sequence, :moderna, :dose_type],
                  expression: "1"
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
                  target: [:injection_sequence, :moderna, :vaccine],
                  column: 2,
                  expression: "moderna"
                },
                %{
                  target: [:injection_sequence, :moderna, :delay_min],
                  column: 3,
                  expression: 0
                },
                %{
                  target: [:injection_sequence, :moderna, :reference_date],
                  column: 5,
                  expression: quote(do: now())
                },
                %{
                  column: 6,
                  target: [:injection_sequence, :moderna, :dose_type],
                  expression: "1"
                }
              ]
            }
          ]
        },
        %{
          description: "MODERNA SEQUENCE END",
          columns: [
            %{variable: [:vaccine_compatibilities, :moderna, :compatible]},
            %{variable: :infection_date},
            %{
              type: "assignment",
              variable: [
                :injection_sequence,
                :moderna,
                :next_injections,
                :moderna,
                :vaccine
              ]
            },
            %{
              type: "assignment",
              variable: [
                :injection_sequence,
                :moderna,
                :next_injections,
                :moderna,
                :delay_min
              ]
            },
            %{
              type: "assignment",
              variable: [
                :injection_sequence,
                :moderna,
                :next_injections,
                :moderna,
                :delay_max
              ]
            },
            %{
              type: "assignment",
              variable: [
                :injection_sequence,
                :moderna,
                :next_injections,
                :moderna,
                :reference_date
              ]
            },
            %{
              type: "assignment",
              variable: [
                :injection_sequence,
                :moderna,
                :next_injections,
                :moderna,
                :dose_type
              ]
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
                  expression: quote(do: is_nil(@infection_date))
                }
              ],
              assignments: [
                %{
                  target: [
                    :injection_sequence,
                    :moderna,
                    :next_injections,
                    :moderna,
                    :vaccine
                  ],
                  column: 2,
                  expression: "moderna"
                },
                %{
                  target: [
                    :injection_sequence,
                    :moderna,
                    :next_injections,
                    :moderna,
                    :delay_min
                  ],
                  column: 3,
                  expression: 28
                },
                %{
                  target: [
                    :injection_sequence,
                    :moderna,
                    :next_injections,
                    :moderna,
                    :delay_max
                  ],
                  column: 4,
                  expression: 35
                },
                %{
                  target: [
                    :injection_sequence,
                    :moderna,
                    :next_injections,
                    :moderna,
                    :dose_type
                  ],
                  column: 6,
                  expression: "2"
                }
              ]
            }
          ]
        },
        %{
          description: "PFIZER SEQUENCE START",
          columns: [
            %{variable: [:vaccine_compatibilities, :pfizer, :compatible]},
            %{variable: :infection_date},
            %{
              type: "assignment",
              variable: [:injection_sequence, :pfizer, :vaccine]
            },
            %{
              type: "assignment",
              variable: [:injection_sequence, :pfizer, :delay_min]
            },
            %{
              type: "assignment",
              variable: [:injection_sequence, :pfizer, :delay_max]
            },
            %{
              type: "assignment",
              variable: [:injection_sequence, :pfizer, :reference_date]
            },
            %{
              type: "assignment",
              variable: [:injection_sequence, :pfizer, :dose_type]
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
                  target: [:injection_sequence, :pfizer, :vaccine],
                  expression: "pfizer"
                },
                %{
                  column: 3,
                  target: [:injection_sequence, :pfizer, :delay_min],
                  expression: 28
                },
                %{
                  column: 5,
                  target: [:injection_sequence, :pfizer, :reference_date],
                  expression: quote(do: @infection_date)
                },
                %{
                  column: 6,
                  target: [:injection_sequence, :pfizer, :dose_type],
                  expression: "1"
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
                  target: [:injection_sequence, :pfizer, :vaccine],
                  column: 2,
                  expression: "pfizer"
                },
                %{
                  target: [:injection_sequence, :pfizer, :delay_min],
                  column: 3,
                  expression: 0
                },
                %{
                  target: [:injection_sequence, :pfizer, :reference_date],
                  column: 5,
                  expression: quote(do: now())
                },
                %{
                  column: 6,
                  target: [:injection_sequence, :pfizer, :dose_type],
                  expression: "1"
                }
              ]
            }
          ]
        },
        %{
          description: "PFIZER SEQUENCE END",
          columns: [
            %{variable: [:vaccine_compatibilities, :pfizer, :compatible]},
            %{variable: :infection_date},
            %{
              type: "assignment",
              variable: [
                :injection_sequence,
                :pfizer,
                :next_injections,
                :pfizer,
                :vaccine
              ]
            },
            %{
              type: "assignment",
              variable: [
                :injection_sequence,
                :pfizer,
                :next_injections,
                :pfizer,
                :delay_min
              ]
            },
            %{
              type: "assignment",
              variable: [
                :injection_sequence,
                :pfizer,
                :next_injections,
                :pfizer,
                :delay_max
              ]
            },
            %{
              type: "assignment",
              variable: [
                :injection_sequence,
                :pfizer,
                :next_injections,
                :pfizer,
                :reference_date
              ]
            },
            %{
              type: "assignment",
              variable: [
                :injection_sequence,
                :pfizer,
                :next_injections,
                :pfizer,
                :dose_type
              ]
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
                  expression: quote(do: is_nil(@infection_date))
                }
              ],
              assignments: [
                %{
                  target: [
                    :injection_sequence,
                    :pfizer,
                    :next_injections,
                    :pfizer,
                    :vaccine
                  ],
                  column: 2,
                  expression: "pfizer"
                },
                %{
                  target: [
                    :injection_sequence,
                    :pfizer,
                    :next_injections,
                    :pfizer,
                    :delay_min
                  ],
                  column: 3,
                  expression: 28
                },
                %{
                  target: [
                    :injection_sequence,
                    :pfizer,
                    :next_injections,
                    :pfizer,
                    :delay_max
                  ],
                  column: 4,
                  expression: 35
                },
                %{
                  target: [
                    :injection_sequence,
                    :pfizer,
                    :next_injections,
                    :pfizer,
                    :dose_type
                  ],
                  column: 6,
                  expression: "2"
                }
              ]
            }
          ]
        },
        %{
          description: "JANSSEN SEQUENCE",
          columns: [
            %{variable: [:vaccine_compatibilities, :janssen, :compatible]},
            %{variable: :infection_date},
            %{
              type: "assignment",
              variable: [:injection_sequence, :janssen, :vaccine]
            },
            %{
              type: "assignment",
              variable: [:injection_sequence, :janssen, :delay_min]
            },
            %{
              type: "assignment",
              variable: [:injection_sequence, :janssen, :delay_max]
            },
            %{
              type: "assignment",
              variable: [:injection_sequence, :janssen, :reference_date]
            },
            %{
              type: "assignment",
              variable: [:injection_sequence, :janssen, :dose_type]
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
                          var([:vaccine_compatibilities, :janssen, :compatible])
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
                  target: [:injection_sequence, :janssen, :vaccine],
                  expression: "janssen"
                },
                %{
                  column: 3,
                  target: [:injection_sequence, :janssen, :delay_min],
                  expression: 28
                },
                %{
                  column: 5,
                  target: [:injection_sequence, :janssen, :reference_date],
                  expression: quote(do: @infection_date)
                },
                %{
                  column: 6,
                  target: [:injection_sequence, :janssen, :dose_type],
                  expression: "1"
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
                          var([:vaccine_compatibilities, :janssen, :compatible])
                        )
                    )
                }
              ],
              assignments: [
                %{
                  column: 2,
                  target: [:injection_sequence, :janssen, :vaccine],
                  expression: "janssen"
                },
                %{
                  column: 3,
                  target: [:injection_sequence, :janssen, :delay_min],
                  expression: 0
                },
                %{
                  column: 5,
                  target: [:injection_sequence, :janssen, :reference_date],
                  expression: quote(do: now())
                },
                %{
                  column: 6,
                  target: [:injection_sequence, :janssen, :dose_type],
                  expression: "1"
                }
              ]
            }
          ]
        },
        %{
          description: "FLAG IMMUNO NEED RECOMMANDATION",
          columns: [
            %{variable: :immuno},
            %{variable: :immuno_discussed},
            %{
              type: "assignment",
              variable: [:flags, :immuno_need_recommendation]
            }
          ],
          branches: [
            %{
              conditions: [
                %{expression: quote(do: is_true(@immuno)), column: 0},
                %{expression: quote(do: is_false(@immuno_discussed)), column: 1}
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
          description: "FLAG IMMUNO NOT RECOMMENDED",
          columns: [
            %{variable: :immuno_discussed},
            %{variable: :immuno_recommended},
            %{type: "assignment", variable: [:flags, :immuno_not_recommended]}
          ],
          branches: [
            %{
              conditions: [
                %{expression: quote(do: is_true(@immuno_discussed)), column: 0},
                %{
                  expression: quote(do: is_false(@immuno_recommended)),
                  column: 1
                }
              ],
              assignments: [
                %{
                  column: 2,
                  target: [:flags, :immuno_not_recommended],
                  expression: true
                }
              ]
            }
          ]
        },
        %{
          description: "FLAG UNDER 12",
          columns: [
            %{variable: :age},
            %{type: "assignment", variable: [:flags, :under_12]}
          ],
          branches: [
            %{
              conditions: [
                %{expression: quote(do: lt(@age, 12)), column: 0}
              ],
              assignments: [
                %{
                  column: 1,
                  target: [:flags, :under_12],
                  expression: true
                }
              ]
            }
          ]
        },
        %{
          description: "FLAG JANSSEN PREGNANT",
          columns: [
            %{variable: :rejects_mrna},
            %{variable: :pregnant},
            %{type: "assignment", variable: [:flags, :janssen_pregnant]}
          ],
          branches: [
            %{
              conditions: [
                %{expression: quote(do: is_true(@rejects_mrna)), column: 0},
                %{expression: quote(do: neq(@pregnant, "no")), column: 1}
              ],
              assignments: [
                %{
                  column: 2,
                  target: [:flags, :janssen_pregnant],
                  expression: true
                }
              ]
            }
          ]
        },
        %{
          description: "FLAG JANSSEN IMMUNO",
          columns: [
            %{variable: :rejects_mrna},
            %{variable: :immuno},
            %{type: "assignment", variable: [:flags, :janssen_immuno]}
          ],
          branches: [
            %{
              conditions: [
                %{expression: quote(do: is_true(@rejects_mrna)), column: 0},
                %{expression: quote(do: is_true(@immuno)), column: 1}
              ],
              assignments: [
                %{
                  column: 2,
                  target: [:flags, :janssen_immuno],
                  expression: true
                }
              ]
            }
          ]
        },
        %{
          description: "FLAG JANSSEN IMMUNO",
          columns: [
            %{variable: :rejects_mrna},
            %{variable: :age},
            %{type: "assignment", variable: [:flags, :janssen_under_18]}
          ],
          branches: [
            %{
              conditions: [
                %{expression: quote(do: is_true(@rejects_mrna)), column: 0},
                %{expression: quote(do: lt(@age, 18)), column: 1}
              ],
              assignments: [
                %{
                  column: 2,
                  target: [:flags, :janssen_under_18],
                  expression: true
                }
              ]
            }
          ]
        }
      ]
    }
  end

  blueprint(:hash0_test) do
    %{
      variables: [
        %{name: :aint, type: :integer, mapping: :in_required, default: 0}
      ]
    }
  end

  blueprint(:hash1_test) do
    %{
      name: :hash1_test,
      variables: [
        %{name: :aint, type: :integer, mapping: :in_required, default: 0},
        %{name: :bint, type: :integer, mapping: :none, default: 0}
      ]
    }
  end

  blueprint(:hash2_test) do
    %{
      variables: [
        %{name: :bint, type: :integer, mapping: :none, default: 0},
        %{name: :aint, type: :integer, mapping: :in_required, default: 0}
      ]
    }
  end

  blueprint(:hash3_test) do
    %{
      name: :hash3_test,
      variables: [
        %{name: :bint, type: :integer, mapping: :in_required, default: 0},
        %{name: :aint, type: :integer, mapping: :in_required, default: 0}
      ]
    }
  end
end
