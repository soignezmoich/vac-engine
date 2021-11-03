%{

  variables: %{

    ### INPUT VARIABLES ###

    birthdate: %{
      type: :date,
      mapping: :in_required,
    },
    previous_vaccination: %{
      type: :map,
      mapping: :in_required,
      children: %{
        last_dose_date: %{
          type: :date,
          mapping: :in_required,
        },
      }
    },

    ### INTERMEDIATE VARIABLES ###
    check_date: %{
      type: :date,
      mapping: :out,
    },
    end_of_birthday_window: %{
      type: :date,
    },
    birthday_65: %{
      type: :date,
    },
    end_of_previous_vaccination_window: %{
      type: :date,
    },
    end_of_previous_vaccination_delay: %{
      type: :date,
    },


    ### OUTPUT VARIABLE ###
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
          }
        },
      },
    },
  },

  deductions: [

    %{
      columns: [
        %{type: "assignment", variable: :end_of_birthday_window}
      ],
      branches: [
        %{
          assignments: [
            %{
              target: :end_of_birthday_window,
              expression: quote(do: add_months(@check_date, 2)),
              column: 0
            }
          ]
        }
      ]
    },

    %{
      columns: [
        %{type: "assignment", variable: :birthday_65}
      ],
      branches: [
        %{
          assignments: [
            %{
              target: :birthday_65,
              expression: quote(do: add_years(@birthdate, 65)),
              column: 0
            }
          ]
        }
      ]
    },

    %{
      columns: [
        %{type: "assignment", variable: :end_of_previous_vaccination_window}
      ],
      branches: [
        %{
          assignments: [
            %{
              target: :end_of_previous_vaccination_window,
              expression: quote(do: add_months(@check_date, 1)),
              column: 0
            }
          ]
        }
      ]
    },

    %{
      columns: [
        %{type: "assignment", variable: :end_of_previous_vaccination_delay}
      ],
      branches: [
        %{
          assignments: [
            %{
              target: :end_of_previous_vaccination_delay,
              expression: quote(do: add_months(var([:previous_vaccination, :last_dose_date]), 6)),
              column: 0
            }
          ]
        }
      ]
    },

    %{
      description: "BOOSTER ELIGIBILITY",
      columns: [
        %{variable: :end_of_previous_vaccination_window},
        %{variable: :end_of_birthday_window},
        %{type: "assignment", variable: [:vaccine_compatibilities, :moderna, :compatible]},
        %{type: "assignment", variable: [:vaccine_compatibilities, :moderna, :priority]},
        %{type: "assignment", variable: [:vaccine_compatibilities, :pfizer, :compatible]},
        %{type: "assignment", variable: [:vaccine_compatibilities, :pfizer, :priority]},
      ],
      branches: [
        %{
          conditions: [
            %{
              expression: quote( do:
                lte(@end_of_previous_vaccination_window, @end_of_previous_vaccination_delay)
              ),
              column: 0
            },
          ],
        },
        %{
          conditions: [
            %{
              expression: quote( do:
                lte(@end_of_birthday_window, @birthday_65)
              ),
              column: 1
            },
          ],
        },
        %{
          assignments: [
            %{
              target: [:vaccine_compatibilities, :moderna, :compatible],
              expression: true,
              column: 2
            },
            %{
              target: [:vaccine_compatibilities, :moderna, :priority],
              expression: 100,
              column: 3
            },
            %{
              target: [:vaccine_compatibilities, :pfizer, :compatible],
              expression: true,
              column: 4
            },
            %{
              target: [:vaccine_compatibilities, :pfizer, :priority],
              expression: 100,
              column: 5
            }
          ]
        },
      ]
    },


    %{
      description: "MODERNA SEQUENCE",
      columns: [
        %{variable: :end_of_previous_vaccination_window},
        %{variable: :end_of_birthday_window},
        %{type: "assignment", variable: [:injection_sequence, :moderna, :vaccine]},
        %{type: "assignment", variable: [:injection_sequence, :moderna, :delay_min]},
        %{type: "assignment", variable: [:injection_sequence, :moderna, :reference_date]},
        %{type: "assignment", variable: [:injection_sequence, :moderna, :dose_type]},
      ],
      branches: [
        %{
          conditions: [
            %{
              expression: quote( do:
                lte(@end_of_previous_vaccination_window, @end_of_previous_vaccination_delay)
              ),
              column: 0
            },
          ],
        },
        %{
          conditions: [
            %{
              expression: quote( do:
                lte(@end_of_birthday_window, @birthday_65)
              ),
              column: 1
            },
          ],
        },
        %{
          assignments: [
            %{
              target: [:injection_sequence, :moderna, :vaccine],
              expression: "moderna",
              column: 2
            },
            %{
              target: [:injection_sequence, :moderna, :delay_min],
              expression: 0,
              column: 3
            },
            %{
              target: [:injection_sequence, :moderna, :reference_date],
              expression: quote( do: latest(@check_date, @end_of_previous_vaccination_delay, @birthday_65)),
              column: 4
            },
            %{
              target: [:injection_sequence, :moderna, :dose_type],
              expression: 0,
              column: 5
            }
          ]
        },
      ]
    },
    %{
      description: "PFIZER SEQUENCE",
      columns: [
        %{variable: :end_of_previous_vaccination_window},
        %{variable: :end_of_birthday_window},
        %{type: "assignment", variable: [:injection_sequence, :pfizer, :vaccine]},
        %{type: "assignment", variable: [:injection_sequence, :pfizer, :delay_min]},
        %{type: "assignment", variable: [:injection_sequence, :pfizer, :reference_date]},
        %{type: "assignment", variable: [:injection_sequence, :pfizer, :dose_type]},
      ],
      branches: [
        %{
          conditions: [
            %{
              expression: quote( do:
                lte(@end_of_previous_vaccination_window, @end_of_previous_vaccination_delay)
              ),
              column: 0
            },
          ],
        },
        %{
          conditions: [
            %{
              expression: quote( do:
                lte(@end_of_birthday_window, @birthday_65)
              ),
              column: 1
            },
          ],
        },
        %{
          assignments: [
            %{
              target: [:injection_sequence, :pfizer, :vaccine],
              expression: "pfizer",
              column: 2
            },
            %{
              target: [:injection_sequence, :pfizer, :delay_min],
              expression: 0,
              column: 3
            },
            %{
              target: [:injection_sequence, :pfizer, :reference_date],
              expression: quote( do: latest(@check_date, @end_of_previous_vaccination_delay, @birthday_65)),
              column: 4
            },
            %{
              target: [:injection_sequence, :pfizer, :dose_type],
              expression: 0,
              column: 5
            }
          ]
        },
      ]
    },


  ]


}
