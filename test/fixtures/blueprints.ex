defmodule Fixtures.Blueprints do
  import Fixtures.Helpers
  use Fixtures.Helpers.Blueprints

  blueprint(:simple_test) do
    %{
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
        previous_vaccination: %{
          type: :map,
          mapping: :in_optional,
          children: %{
            vaccine: %{
              type: :string,
              mapping: :in_optional,
              enum: ["moderna", "pfizer"]
            },
            last_dose_date: %{
              type: :date,
              mapping: :in_optional
            }
          }
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
          type: :integer,
          mapping: :out
        },
        eligible: %{
          type: :boolean
        },
        registrable_if_dose_within: %{
          type: :integer,
          mapping: :out
        },
        flags: %{
          type: :map,
          mapping: :out,
          children: %{
            need_determine_pregnant: %{type: :boolean, mapping: :out},
            immuno_need_recommendation: %{type: :boolean, mapping: :out},
            infection: %{type: :boolean, mapping: :out},
            not_yet_eligible_for_booster: %{type: :boolean, mapping: :out}
          }
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
        }
      },
      deductions: [
        %{
          columns: [
            %{description: "Age", variable: :age, type: "assignment"}
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
            %{description: "Infection date", variable: :infection_date},
            %{
              description: "Registrable if dose within",
              variable: :registrable_if_dose_within,
              type: "assignment"
            }
          ],
          branches: [
            %{
              conditions: [
                %{expression: quote(do: is_not_nil(@infection_date)), column: 0}
              ],
              assignments: [
                %{
                  target: :registrable_if_dose_within,
                  expression: 20,
                  column: 1
                }
              ]
            },
            %{
              assignments: [
                %{
                  target: :registrable_if_dose_within,
                  expression: 30,
                  column: 1
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
            %{description: "Rejects mrna", variable: :rejects_mrna},
            %{description: "Pregnant", variable: :pregnant},
            %{
              description: "Previous vaccine",
              variable: [:previous_vaccination, :vaccine]
            },
            %{
              description: "Moderna compatibility",
              variable: [:vaccine_compatibilities, :moderna, :compatible],
              type: "assignment"
            },
            %{
              description: "Pfizer compatibility",
              variable: [:vaccine_compatibilities, :pfizer, :compatible],
              type: "assignment"
            },
            %{
              description: "Janssen compatibility",
              variable: [:vaccine_compatibilities, :janssen, :compatible],
              type: "assignment"
            }
          ],
          branches: [
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 65)), column: 0},
                %{
                  expression:
                    quote(
                      do: is_not_nil(var([:previous_vaccination, :vaccine]))
                    ),
                  column: 5
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :compatible],
                  description: "previous_vaccination",
                  column: 6,
                  expression:
                    quote(
                      do:
                        eq(
                          var([:previous_vaccination, :vaccine]),
                          "moderna"
                        )
                    )
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "previous_vaccination",
                  column: 7,
                  expression:
                    quote(
                      do:
                        eq(
                          var([:previous_vaccination, :vaccine]),
                          "pfizer"
                        )
                    )
                },
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "previous_vaccination",
                  column: 8,
                  expression: false
                }
              ]
            },
            %{
              conditions: [
                %{
                  expression:
                    quote(
                      do: is_not_nil(var([:previous_vaccination, :vaccine]))
                    ),
                  column: 5
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :compatible],
                  description: "not_eligible_for_booster",
                  column: 6,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "not_eligible_for_booster",
                  column: 7,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "not_eligible_for_booster",
                  column: 8,
                  expression: false
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: lt(@age, 12)), column: 0}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :compatible],
                  description: "younger_than_12",
                  column: 6,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "younger_than_12",
                  column: 7,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "younger_than_12",
                  column: 8,
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
                  column: 6,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "immuno_no_recommendation",
                  column: 7,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "immuno_no_recommendation",
                  column: 8,
                  expression: false
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: is_true(@rejects_mrna)), column: 3},
                %{expression: quote(do: neq(@pregnant, "no")), column: 4}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :compatible],
                  description: "rejects_mrna_vaccines",
                  column: 6,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "rejects_mrna_vaccines",
                  column: 7,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "pregnant",
                  column: 8,
                  expression: false
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: lt(@age, 18)), column: 0},
                %{expression: quote(do: is_true(@rejects_mrna)), column: 3}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :compatible],
                  description: "rejects_mrna_vaccines",
                  column: 6,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "rejects_mrna_vaccines",
                  column: 7,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "younger_than_18",
                  column: 8,
                  expression: false
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: is_true(@immuno)), column: 1},
                %{
                  expression: quote(do: is_true(@immuno_recommended)),
                  column: 2
                },
                %{expression: quote(do: is_true(@rejects_mrna)), column: 3}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :compatible],
                  description: "rejects_mrna_vaccines",
                  column: 6,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "rejects_mrna_vaccines",
                  column: 7,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "immuno",
                  column: 8,
                  expression: false
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: is_true(@rejects_mrna)), column: 3}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :compatible],
                  description: "rejects_mrna_vaccines",
                  column: 6,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "rejects_mrna_vaccines",
                  column: 7,
                  expression: false
                },
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "rejects_mrna_vaccines",
                  column: 8,
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
                  column: 6,
                  expression: true
                },
                %{
                  target: [:vaccine_compatibilities, :pfizer, :compatible],
                  description: "other",
                  column: 7,
                  expression: true
                },
                %{
                  target: [:vaccine_compatibilities, :janssen, :compatible],
                  description: "other",
                  column: 8,
                  expression: false
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
            %{
              description: "Janssen compatibility",
              variable: [:vaccine_compatibilities, :janssen, :compatible]
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
          columns: [
            %{
              description: "Moderna compatibility",
              variable: [:vaccine_compatibilities, :moderna, :compatible]
            },
            %{description: "Age", variable: :age},
            %{description: "High risk", variable: :high_risk},
            %{description: "Immuno recommended", variable: :immuno_recommended},
            %{description: "Healthcare worker", variable: :healthcare_worker},
            %{description: "High risk contact", variable: :high_risk_contact},
            %{description: "Community facility", variable: :community_facility},
            %{
              description: "Moderna priority",
              variable: [:vaccine_compatibilities, :moderna, :priority],
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
                  column: 7,
                  expression: -1
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 75)), column: 1}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :priority],
                  description: "older_than_75",
                  column: 7,
                  expression: 1
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: is_true(@high_risk)), column: 2}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :priority],
                  description: "high_risk",
                  column: 7,
                  expression: 1
                }
              ]
            },
            %{
              conditions: [
                %{
                  expression: quote(do: is_true(@immuno_recommended)),
                  column: 3
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :priority],
                  description: "immuno",
                  column: 7,
                  expression: 1
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 65)), column: 1}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :priority],
                  description: "older_than_65",
                  column: 7,
                  expression: 2
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 60)), column: 1}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :priority],
                  description: "older_than_60",
                  column: 7,
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
                  description: "healthcare_worker",
                  column: 7,
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
                  description: "high_risk_contact",
                  column: 7,
                  expression: 5
                }
              ]
            },
            %{
              conditions: [
                %{
                  expression: quote(do: is_true(@community_facility)),
                  column: 6
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :moderna, :priority],
                  description: "community_facility",
                  column: 7,
                  expression: 6
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
                }
              ]
            }
          ]
        },
        %{
          columns: [
            %{
              description: "Pfizer compatibility",
              variable: [:vaccine_compatibilities, :pfizer, :compatible]
            },
            %{description: "Age", variable: :age},
            %{description: "High risk", variable: :high_risk},
            %{description: "Immuno recommended", variable: :immuno_recommended},
            %{description: "Healthcare worker", variable: :healthcare_worker},
            %{description: "High risk contact", variable: :high_risk_contact},
            %{description: "Community facility", variable: :community_facility},
            %{
              description: "Moderna priority",
              variable: [:vaccine_compatibilities, :pfizer, :priority],
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
                        is_false(
                          var([:vaccine_compatibilities, :pfizer, :compatible])
                        )
                    )
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "not_pfizer_compatible",
                  column: 7,
                  expression: -1
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 75)), column: 1}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "older_than_75",
                  column: 7,
                  expression: 1
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: is_true(@high_risk)), column: 2}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "high_risk",
                  column: 7,
                  expression: 1
                }
              ]
            },
            %{
              conditions: [
                %{
                  expression: quote(do: is_true(@immuno_recommended)),
                  column: 3
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "immuno",
                  column: 7,
                  expression: 1
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 65)), column: 1}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "older_than_65",
                  column: 7,
                  expression: 2
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 60)), column: 1}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "older_than_60",
                  column: 7,
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
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "healthcare_worker",
                  column: 7,
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
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "high_risk_contact",
                  column: 7,
                  expression: 5
                }
              ]
            },
            %{
              conditions: [
                %{
                  expression: quote(do: is_true(@community_facility)),
                  column: 6
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "community_facility",
                  column: 7,
                  expression: 6
                }
              ]
            },
            %{
              conditions: [],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :pfizer, :priority],
                  description: "other",
                  column: 7,
                  expression: 7
                }
              ]
            }
          ]
        },
        %{
          columns: [
            %{
              description: "Janssen compatibility",
              variable: [:vaccine_compatibilities, :janssen, :compatible]
            },
            %{description: "Age", variable: :age},
            %{description: "High risk", variable: :high_risk},
            %{description: "Healthcare worker", variable: :healthcare_worker},
            %{description: "High risk contact", variable: :high_risk_contact},
            %{description: "Community facility", variable: :community_facility},
            %{
              description: "Janssen priority",
              variable: [:vaccine_compatibilities, :janssen, :priority],
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
                  column: 6,
                  expression: -1
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 75)), column: 1}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :priority],
                  description: "older_than_75",
                  column: 6,
                  expression: 1
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: is_true(@high_risk)), column: 2}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :priority],
                  description: "high_risk",
                  column: 6,
                  expression: 1
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 65)), column: 1}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :priority],
                  description: "older_than_65",
                  column: 6,
                  expression: 2
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: gte(@age, 60)), column: 1}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :priority],
                  description: "older_than_60",
                  column: 6,
                  expression: 3
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: is_true(@healthcare_worker)), column: 3}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :priority],
                  description: "healthcare worker",
                  column: 6,
                  expression: 4
                }
              ]
            },
            %{
              conditions: [
                %{expression: quote(do: is_true(@high_risk_contact)), column: 4}
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :priority],
                  description: "high risk contact",
                  column: 6,
                  expression: 5
                }
              ]
            },
            %{
              conditions: [
                %{
                  expression: quote(do: is_true(@community_facility)),
                  column: 5
                }
              ],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :priority],
                  description: "community facility",
                  column: 6,
                  expression: 6
                }
              ]
            },
            %{
              conditions: [],
              assignments: [
                %{
                  target: [:vaccine_compatibilities, :janssen, :priority],
                  description: "other",
                  column: 6,
                  expression: 7
                }
              ]
            }
          ]
        },
        %{
          columns: [
            %{
              description: "Pregnant",
              variable: :pregnant
            },
            %{
              description: "Need check pregnant",
              variable: [:flags, :need_determine_pregnant],
              type: "assignment"
            }
          ],
          branches: [
            %{
              conditions: [
                %{
                  expression: quote(do: eq(@pregnant, "unknown")),
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
              description: "Immuno discussed",
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
                %{
                  expression: quote(do: is_not_nil(@infection_date)),
                  column: 0
                },
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
              description: "Last dose date",
              variable: :previous_vaccination
            },
            %{
              description: "Eligible",
              variable: :eligible
            },
            %{
              description: "Not yet eligible for booster",
              variable: [:flags, :not_yet_eligible_for_booster],
              type: "assignment"
            }
          ],
          branches: [
            %{
              conditions: [
                %{
                  expression: quote(do: is_not_nil(@previous_vaccination)),
                  column: 0
                },
                %{expression: quote(do: lt(@age, 65)), column: 1}
              ],
              assignments: [
                %{
                  target: [:flags, :not_yet_eligible_for_booster],
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
              description: "Previous vaccination",
              variable: :previous_vaccination
            },
            %{
              description: "Infection date",
              variable: :infection_date
            },
            %{
              description: "Vaccine",
              variable: [:injection_sequence, :moderna, :vaccine],
              type: "assignment"
            },
            %{
              description: "Delay min",
              variable: [:injection_sequence, :moderna, :delay_min],
              type: "assignment"
            },
            %{
              description: "Delay max",
              variable: [:injection_sequence, :moderna, :delay_max],
              type: "assignment"
            },
            %{
              description: "Reference date",
              variable: [:injection_sequence, :moderna, :reference_date],
              type: "assignment"
            },
            %{
              description: "Next injection Vaccine",
              variable: [
                :injection_sequence,
                :moderna,
                :next_injections,
                :moderna,
                :vaccine
              ],
              type: "assignment"
            },
            %{
              description: "Next injection Delay min",
              variable: [
                :injection_sequence,
                :moderna,
                :next_injections,
                :moderna,
                :delay_min
              ],
              type: "assignment"
            },
            %{
              description: "Next injection Delay max",
              variable: [
                :injection_sequence,
                :moderna,
                :next_injections,
                :moderna,
                :delay_max
              ],
              type: "assignment"
            },
            %{
              description: "Next injection Reference date",
              variable: [
                :injection_sequence,
                :moderna,
                :next_injections,
                :moderna,
                :reference_date
              ],
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
                  expression: quote(do: is_not_nil(@previous_vaccination))
                }
              ],
              assignments: [
                %{
                  column: 3,
                  target: [:injection_sequence, :moderna, :vaccine],
                  expression: "moderna"
                },
                %{
                  column: 4,
                  target: [:injection_sequence, :moderna, :delay_min],
                  expression: 182
                },
                %{
                  column: 6,
                  target: [:injection_sequence, :moderna, :reference_date],
                  expression:
                    quote(do: var([:previous_vaccination, :last_dose_date]))
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
                },
                %{
                  column: 2,
                  expression: quote(do: is_not_nil(@infection_date))
                }
              ],
              assignments: [
                %{
                  column: 3,
                  target: [:injection_sequence, :moderna, :vaccine],
                  expression: "moderna"
                },
                %{
                  column: 4,
                  target: [:injection_sequence, :moderna, :delay_min],
                  expression: 28
                },
                %{
                  column: 6,
                  target: [:injection_sequence, :moderna, :reference_date],
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
                  target: [:injection_sequence, :moderna, :vaccine],
                  column: 3,
                  expression: "moderna"
                },
                %{
                  target: [:injection_sequence, :moderna, :delay_min],
                  column: 4,
                  expression: 0
                },
                %{
                  target: [:injection_sequence, :moderna, :reference_date],
                  column: 6,
                  expression: quote(do: now())
                },
                %{
                  target: [
                    :injection_sequence,
                    :moderna,
                    :next_injections,
                    :moderna,
                    :vaccine
                  ],
                  column: 7,
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
                  column: 8,
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
                  column: 9,
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
              description: "Previous vaccination",
              variable: :previous_vaccination
            },
            %{
              description: "Infection date",
              variable: :infection_date
            },
            %{
              description: "Vaccine",
              variable: [:injection_sequence, :pfizer, :vaccine],
              type: "assignment"
            },
            %{
              description: "Delay min",
              variable: [:injection_sequence, :pfizer, :delay_min],
              type: "assignment"
            },
            %{
              description: "Delay max",
              variable: [:injection_sequence, :pfizer, :delay_max],
              type: "assignment"
            },
            %{
              description: "Reference date",
              variable: [:injection_sequence, :pfizer, :reference_date],
              type: "assignment"
            },
            %{
              description: "Next injection Vaccine",
              variable: [
                :injection_sequence,
                :pfizer,
                :next_injections,
                :pfizer,
                :vaccine
              ],
              type: "assignment"
            },
            %{
              description: "Next injection Delay min",
              variable: [
                :injection_sequence,
                :pfizer,
                :next_injections,
                :pfizer,
                :delay_min
              ],
              type: "assignment"
            },
            %{
              description: "Next injection Delay max",
              variable: [
                :injection_sequence,
                :pfizer,
                :next_injections,
                :pfizer,
                :delay_max
              ],
              type: "assignment"
            },
            %{
              description: "Next injection Reference date",
              variable: [
                :injection_sequence,
                :pfizer,
                :next_injections,
                :pfizer,
                :reference_date
              ],
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
                  expression: quote(do: is_not_nil(@previous_vaccination))
                }
              ],
              assignments: [
                %{
                  column: 3,
                  target: [:injection_sequence, :pfizer, :vaccine],
                  expression: "pfizer"
                },
                %{
                  column: 4,
                  target: [:injection_sequence, :pfizer, :delay_min],
                  expression: 182
                },
                %{
                  column: 6,
                  target: [:injection_sequence, :pfizer, :reference_date],
                  expression:
                    quote(do: var([:previous_vaccination, :last_dose_date]))
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
                },
                %{
                  column: 2,
                  expression: quote(do: is_not_nil(@infection_date))
                }
              ],
              assignments: [
                %{
                  column: 3,
                  target: [:injection_sequence, :pfizer, :vaccine],
                  expression: "pfizer"
                },
                %{
                  column: 4,
                  target: [:injection_sequence, :pfizer, :delay_min],
                  expression: 28
                },
                %{
                  column: 6,
                  target: [:injection_sequence, :pfizer, :reference_date],
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
                  column: 3,
                  target: [:injection_sequence, :pfizer, :vaccine],
                  expression: "pfizer"
                },
                %{
                  column: 4,
                  target: [:injection_sequence, :pfizer, :delay_min],
                  expression: 0
                },
                %{
                  column: 6,
                  target: [:injection_sequence, :pfizer, :reference_date],
                  expression: quote(do: now())
                },
                %{
                  column: 7,
                  target: [
                    :injection_sequence,
                    :pfizer,
                    :next_injections,
                    :pfizer,
                    :vaccine
                  ],
                  expression: "pfizer"
                },
                %{
                  column: 8,
                  target: [
                    :injection_sequence,
                    :pfizer,
                    :next_injections,
                    :pfizer,
                    :delay_min
                  ],
                  expression: 28
                },
                %{
                  column: 9,
                  target: [
                    :injection_sequence,
                    :pfizer,
                    :next_injections,
                    :pfizer,
                    :delay_max
                  ],
                  expression: 35
                }
              ]
            }
          ]
        },
        %{
          columns: [
            %{
              description: "Janssen compatible",
              variable: [:vaccine_compatibilities, :janssen, :compatible]
            },
            %{
              description: "Infection date",
              variable: :infection_date
            },
            %{
              description: "Vaccine",
              variable: [:injection_sequence, :janssen, :vaccine],
              type: "assignment"
            },
            %{
              description: "Delay min",
              variable: [:injection_sequence, :janssen, :delay_min],
              type: "assignment"
            },
            %{
              description: "Delay max",
              variable: [:injection_sequence, :janssen, :delay_max],
              type: "assignment"
            },
            %{
              description: "Reference date",
              variable: [:injection_sequence, :janssen, :reference_date],
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
