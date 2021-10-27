%{

  #############################################################################
  #### VARIABLES ##############################################################
  #############################################################################

  variables: %{


    ######## INPUT ############################################################
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
    previous_vaccination: %{
      type: :map,
      mapping: :in_optional,
      children: %{
        vaccine: %{
          type: :string,
          mapping: :in_optional,
          enum: ["moderna", "pfizer", "other"]
        },
        last_dose_date: %{
          type: :date,
          mapping: :in_optional
        },
        doses_count: %{
          type: :integer,
          mapping: :in_optional
        }
      }
    },


    ######## INTERMEDIATE #####################################################
    age: %{
      type: :integer
    },
    eligible: %{
      type: :boolean
    },


    ######## OUTPUT ###########################################################
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
            onedoc: %{
              type: :map,
              mapping: :out,
              children: %{
                previous_vaccination_vaccine: %{type: :string, mapping: :out, enum: ["moderna", "pfizer"]},
                previous_vaccination_doses_count: %{type: :integer, mapping: :out},
                previous_vaccination_last_dose_date: %{type: :date, mapping: :out}
              }
            },
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



  #############################################################################
  #### DEDUCTIONS #############################################################
  #############################################################################

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



   ##### COMPATIBILITY ########################################################

    %{
      description: "MODERNA & PFIZER COMPATIBILITY",
      columns: [
        %{variable: :previous_vaccination},
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
            %{
              expression:
                quote(do:
                  eq(var([:previous_vaccination, :vaccine]), "pfizer")
                ),
              column: 0
            },
            %{expression: quote(do: gte(@age, 65)), column: 4}
          ],
          assignments: [
            %{
              target: [:vaccine_compatibilities, :moderna, :compatible],
              description: "booster_only_for_pfizer",
              column: 5,
              expression: false
            },
            %{
              target: [:vaccine_compatibilities, :pfizer, :compatible],
              description: "pfizer_booster",
              column: 6,
              expression: true
            }
          ]
        },
        %{
          conditions: [
            %{
              expression:
                quote(do:
                  is_not_nil(var([:previous_vaccination, :vaccine]))
                ),
              column: 0
            },
          ],
          assignments: [
            %{
              target: [:vaccine_compatibilities, :moderna, :compatible],
              description: "no_booster_for_younger_than_65",
              column: 5,
              expression: false
            },
            %{
              target: [:vaccine_compatibilities, :pfizer, :compatible],
              description: "no_booster_for_younger_than_65",
              column: 6,
              expression: false
            }
          ]
        },
        %{
          conditions: [
            %{expression: quote(do: is_true(@rejects_mrna)), column: 1}
          ],
          assignments: [
            %{
              target: [:vaccine_compatibilities, :moderna, :compatible],
              description: "rejects_mrna",
              column: 5,
              expression: false
            },
            %{
              target: [:vaccine_compatibilities, :pfizer, :compatible],
              description: "rejects_mrna",
              column: 6,
              expression: false
            }
          ]
        },
        %{
          conditions: [
            %{expression: quote(do: is_true(@immuno)), column: 2},
            %{
              expression: quote(do: is_false(@immuno_recommended)),
              column: 3
            }
          ],
          assignments: [
            %{
              target: [:vaccine_compatibilities, :moderna, :compatible],
              description: "immuno_no_recommendation",
              column: 5,
              expression: false
            },
            %{
              target: [:vaccine_compatibilities, :pfizer, :compatible],
              description: "immuno_no_recommendation",
              column: 6,
              expression: false
            }
          ]
        },
        %{
          conditions: [
            %{expression: quote(do: lt(@age, 12)), column: 4}
          ],
          assignments: [
            %{
              target: [:vaccine_compatibilities, :moderna, :compatible],
              description: "younger_than_12",
              column: 5,
              expression: false
            },
            %{
              target: [:vaccine_compatibilities, :pfizer, :compatible],
              description: "younger_than_12",
              column: 6,
              expression: false
            }
          ]
        },
        %{
          conditions: [
            %{expression: quote(do: lt(@age, 16)), column: 4}
          ],
          assignments: [
            %{
              target: [:vaccine_compatibilities, :moderna, :compatible],
              description: "younger_than_16",
              column: 5,
              expression: false
            },
            %{
              target: [:vaccine_compatibilities, :pfizer, :compatible],
              description: "other",
              column: 6,
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
              column: 5,
              expression: true
            },
            %{
              target: [:vaccine_compatibilities, :pfizer, :compatible],
              description: "other",
              column: 6,
              expression: true
            }
          ]
        }
      ]
    },
    %{
      description: "JANSSEN COMPATIBILITY",
      columns: [
        %{variable: [:previous_vaccination, :vaccine]},
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
            %{
              expression:
                quote(do:
                  is_not_nil(var([:previous_vaccination, :vaccine]))
                ),
              column: 0
            },
          ],
          assignments: [
            %{
              target: [:vaccine_compatibilities, :janssen, :compatible],
              description: "no_janssen_booster",
              column: 5,
              expression: false
            }
          ]
        },
        %{
          conditions: [
            %{expression: quote(do: is_false(@rejects_mrna)), column: 1}
          ],
          assignments: [
            %{
              target: [:vaccine_compatibilities, :janssen, :compatible],
              description: "accepts_mrna",
              column: 5,
              expression: false
            }
          ]
        },
        %{
          conditions: [
            %{expression: quote(do: is_true(@immuno)), column: 2}
          ],
          assignments: [
            %{
              target: [:vaccine_compatibilities, :janssen, :compatible],
              description: "immuno",
              column: 5,
              expression: false
            }
          ]
        },
        %{
          conditions: [
            %{expression: quote(do: neq(@pregnant, "no")), column: 3}
          ],
          assignments: [
            %{
              target: [:vaccine_compatibilities, :janssen, :compatible],
              description: "pregnant",
              column: 5,
              expression: false
            }
          ]
        },
        %{
          conditions: [
            %{expression: quote(do: lt(@age, 18)), column: 4}
          ],
          assignments: [
            %{
              target: [:vaccine_compatibilities, :janssen, :compatible],
              description: "younger_than_18",
              column: 5,
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
              column: 5,
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


    ##### PRIORITY ########################################################

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



    ##### SEQUENCES ###########################################################


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
        %{variable: :previous_vaccination},
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
            },
            %{
              column: 7,
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
            },
            %{
              column: 2,
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
              expression: 181
            },
            %{
              column: 6,
              target: [:injection_sequence, :pfizer, :reference_date],
              expression: quote(do: var([:previous_vaccination, :last_dose_date]))
            },
            %{
              column: 7,
              target: [:injection_sequence, :pfizer, :dose_type],
              expression: "0"
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
              column: 3,
              expression: "pfizer"
            },
            %{
              target: [:injection_sequence, :pfizer, :delay_min],
              column: 4,
              expression: 0
            },
            %{
              target: [:injection_sequence, :pfizer, :reference_date],
              column: 6,
              expression: quote(do: now())
            },
            %{
              column: 7,
              target: [:injection_sequence, :pfizer, :dose_type],
              expression: "1"
            }
          ]
        }
      ]
    },
    %{
      description: "PFIZER ONEDOC PREVIOUS VACCINATION INFOS",
      columns: [
        %{variable: [:vaccine_compatibilities, :pfizer, :compatible]},
        %{variable: :previous_vaccination},
        %{
          type: "assignment",
          variable: [
            :injection_sequence,
            :pfizer,
            :onedoc,
            :previous_vaccination_vaccine
          ]
        },
        %{
          type: "assignment",
          variable: [
            :injection_sequence,
            :pfizer,
            :onedoc,
            :previous_vaccination_doses_count
          ]
        },
        %{
          type: "assignment",
          variable: [
            :injection_sequence,
            :pfizer,
            :onedoc,
            :previous_vaccination_last_dose_date
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
              expression: quote(do: is_not_nil(@previous_vaccination))
            }
          ],
          assignments: [
            %{
              target: [:injection_sequence, :pfizer, :onedoc, :previous_vaccination_vaccine],
              column: 2,
              expression: quote(do: var([:previous_vaccination, :vaccine]))
            },
            %{
              target: [:injection_sequence, :pfizer, :onedoc, :previous_vaccination_doses_count],
              column: 3,
              expression: quote(do: var([:previous_vaccination, :doses_count]))
            },
            %{
              target: [:injection_sequence, :pfizer, :onedoc, :previous_vaccination_last_dose_date],
              column: 4,
              expression: quote(do: var([:previous_vaccination, :last_dose_date]))
            },
          ]
        }
      ]
    },
    %{
      description: "PFIZER SEQUENCE END",
      columns: [
        %{variable: [:vaccine_compatibilities, :pfizer, :compatible]},
        %{variable: :infection_date},
        %{variable: :previous_vaccination},
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
            },
            %{
              column: 2,
              expression: quote(do: is_nil(@previous_vaccination))
            },
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
              column: 3,
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
              column: 4,
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
              column: 5,
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
              column: 7,
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
        %{variable: :immuno_recommended},
        %{
          type: "assignment",
          variable: [:flags, :immuno_need_recommendation]
        }
      ],
      branches: [
        %{
          conditions: [
            %{expression: quote(do: is_true(@immuno)), column: 0},
            %{expression: quote(do: is_true(@immuno_discussed)), column: 2}
          ]
        },
        %{
          conditions: [
            %{expression: quote(do: is_true(@immuno)), column: 0},
            %{expression: quote(do: is_false(@immuno_discussed)), column: 1}
          ],
          assignments: [
            %{
              column: 3,
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
