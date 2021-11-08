%{

  id: 9,

  #############################################################################
  #### VARIABLES ##############################################################
  #############################################################################

  variables: %{


    ######## INPUT ############################################################
    birthdate: %{
      type: :date,
      mapping: :in_required
    },
    high_risk: %{
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
          enum: ["moderna", "pfizer", "janssen", "other"]
        },
        last_dose_date: %{
          type: :date,
          mapping: :in_optional
        },
      }
    },


    ######## INTERMEDIATE #####################################################
    check_date: %{
      type: :date,
    },
    end_of_registration_window: %{
      type: :date,
    },
    age: %{
      type: :integer
    },
    eligible: %{
      type: :boolean
    },
    birthday_12: %{
      type: :date
    },
    birthday_65: %{
      type: :date
    },
    end_of_infection_delay: %{
      type: :date,
    },
    end_of_booster_delay: %{
      type: :date,
    },
    end_of_delays_moderna: %{
      type: :date,
    },
    end_of_delays_pfizer: %{
      type: :date,
    },
    booster_compatibilities: %{
      type: :map,
      children: %{
        moderna: %{
          type: :boolean,
        },
        pfizer: %{
          type: :boolean,
        }
      }
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
              enum: ["moderna", "pfizer"]
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
                previous_vaccination_last_dose_date: %{type: :date, mapping: :out}
              }
            },
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
                previous_vaccination_last_dose_date: %{type: :date, mapping: :out}
              }
            }
          }
        },
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
        under_12: %{type: :boolean, mapping: :out},
        booster_only_after_moderna_or_pfizer: %{type: :boolean, mapping: :out},
      }
    }
  },



  #############################################################################
  #### DEDUCTIONS #############################################################
  #############################################################################

  deductions: [
    %{
      columns: [
        %{type: "assignment", variable: :check_date}
      ],
      branches: [
        %{
          conditions: [],
          assignments: [
            %{
              target: :check_date,
              expression: quote(do: now()),
              column: 0
            }
          ]
        }
      ]
    },
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
      columns: [
        %{type: "assignment", variable: :end_of_registration_window}
      ],
      branches: [
        %{
          assignments: [
            %{
              target: :end_of_registration_window,
              expression: quote(do: add_days(@check_date, @registrable_if_dose_within)),
              column: 0
            }
          ]
        }
      ]
    },
    %{
      columns: [
        %{type: "assignment", variable: :end_of_booster_delay}
      ],
      branches: [
        %{
          assignments: [
            %{
              target: :end_of_booster_delay,
              expression: quote(do: add_months(var(["previous_vaccination", "last_dose_date"]), 6)),
              column: 0
            }
          ]
        }
      ]
    },
    %{
      columns: [
        %{variable: :infection_date},
        %{variable: [:previous_vaccination, :vaccine]},
        %{variable: [:previous_vaccination, :last_dose_date]},
        %{type: "assignment", variable: :end_of_infection_delay},
      ],
      branches: [
        %{
          conditions: [
            %{
              column: 0,
              expression: quote(do: is_nil(@infection_date))
            },
          ]
        },
        %{
          conditions: [
            %{
              column: 1,
              expression: quote(do: is_not_nil(var(:previous_vaccination)))
            },
            %{
              column: 2,
              expression: quote(do: lt(var([:previous_vaccination, :last_dose_date]), @infection_date))
            }
          ],
          assignments: [
            %{
              target: :end_of_infection_delay,
              expression: quote(do: add_months(@infection_date, 6)),
              column: 3
            }
          ]
        },
        %{
          assignments: [
            %{
              target: :end_of_infection_delay,
              expression: quote(do: add_days(@infection_date, 28)),
              column: 3
            }
          ]
        }
      ]
    },
    %{
      columns: [
        %{type: "assignment", variable: :birthday_12}
      ],
      branches: [
        %{
          assignments: [
            %{
              target: :birthday_12,
              expression: quote(do: add_years(@birthdate, 12)),
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


   ##### GLOBAL ##############################################################

  %{
    description: "AGE CHECK", # TODO add janssen, moderna special ages
    columns: [
      %{variable: :end_of_registration_window},
      %{type: "assignment", variable: [:flags, :under_12]},
    ],
    branches: [
      %{
        conditions: [
          %{
            expression: quote(do:
              lt(@end_of_registration_window, @birthday_12)
            ),
            column: 0
          }
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


  ##### MODERNA COMPATIBILITY #################################################

  %{
    description: "MODERNA BOOSTER COMPATIBILITY",
    columns: [
      %{variable: [:previous_vaccination, :vaccine]},
      %{variable: :end_of_registration_window},
      %{variable: :previous_vaccination},
      %{variable: :high_risk},
      %{type: "assignment", variable: [:booster_compatibilities, :moderna]},
    ],
    branches: [
      %{
        conditions: [
          %{
            column: 0,
            expression: quote(do:
              neq(var([:previous_vaccination, :vaccine]), "moderna")
            ),
          }
        ],
        assignments: [
          %{
            column: 4,
            description: "not_same_vaccine",
            expression: false,
            target: [:booster_compatibilities, :moderna],
          }
        ]
      },
      %{
        conditions: [
          %{
            expression: quote(do:
              lt(@end_of_registration_window, @end_of_booster_delay)
            ),
            column: 1
          }
        ],
        assignments: [
          %{
            column: 4,
            description: "too_early",
            expression: false,
            target: [:booster_compatibilities, :moderna],
          }
        ]
      },
      %{
        conditions: [
          %{
            expression: quote(do:
              lt(@end_of_registration_window, @birthday_65)
            ),
            column: 1
          },
          %{
            column: 3,
            expression: quote(do: is_false(@high_risk)),
          }
        ],
        assignments: [
          %{
            description: "too_young_not_high_risk",
            column: 4,
            target: [:booster_compatibilities, :moderna],
            expression: false
          }
        ]
      },
      %{
        conditions: [],
        assignments: [
          %{
            description: "compatible",
            column: 4,
            target: [:booster_compatibilities, :moderna],
            expression: true
          }
        ]
      }
    ]
  },


  %{
    description: "MODERNA COMPATIBILITY",
    columns: [
      %{variable: :end_of_infection_delay},
      %{variable: [:previous_vaccination, :vaccine]},
      %{variable: [:booster_compatibilities, :moderna]},
      %{variable: :end_of_registration_window},
      %{variable: :high_risk},
      %{type: "assignment", variable: [:vaccine_compatibilities, :moderna, :compatible]},
      %{type: "assignment", variable: :end_of_delays_moderna}
    ],
    branches: [
      %{
        conditions: [
          %{
            column: 3,
            expression: quote(do: lt(@end_of_registration_window, @birthday_12)),
          }
        ],
        assignments: [
          %{
            description: "younger_than_12",
            column: 5,
            target: [:vaccine_compatibilities, :moderna, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 0,
            expression: quote(do: gt(@end_of_infection_delay, @end_of_registration_window)),
          }
        ],
        assignments: [
          %{
            description: "recently_infected",
            column: 5,
            target: [:vaccine_compatibilities, :moderna, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 1,
            expression: quote(do: is_nil(var([:previous_vaccination, :vaccine]))),
          },
        ],
        assignments: [
          %{
            description: "not_booster_candidate",
            column: 5,
            target: [:vaccine_compatibilities, :moderna, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 2,
            expression: quote(do: is_false(var([:booster_compatibilities, :moderna]))),
          },
        ],
        assignments: [
          %{
            description: "incompatible_with_moderna_booster",
            column: 5,
            target: [:vaccine_compatibilities, :moderna, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 4,
            expression: quote(do: is_true(@high_risk)),
          },
        ],
        assignments: [
          %{
            description: "moderna_booster",
            column: 5,
            target: [:vaccine_compatibilities, :moderna, :compatible],
            expression: true
          },
          %{
            column: 6,
            target: :end_of_delays_moderna,
            expression: quote(do: latest(@end_of_infection_delay, @end_of_booster_delay))
          }
        ],
      },
      %{
        assignments: [
          %{
            description: "moderna_booster",
            column: 5,
            target: [:vaccine_compatibilities, :moderna, :compatible],
            expression: true
          },
          %{
            column: 6,
            target: :end_of_delays_moderna,
            expression: quote(do: latest(@end_of_infection_delay, @end_of_booster_delay, @birthday_65))
          }
        ],
      }
    ]
  },


  ##### PFIZER COMPATIBILITY #######################################################


  %{
    description: "PFIZER BOOSTER COMPATIBILITY",
    columns: [
      %{variable: [:previous_vaccination, :vaccine]},
      %{variable: :end_of_registration_window},
      %{variable: :previous_vaccination},
      %{variable: :high_risk},
      %{type: "assignment", variable: [:booster_compatibilities, :pfizer]},
    ],
    branches: [
      %{
        conditions: [
          %{
            column: 0,
            expression: quote(do:
              neq(var([:previous_vaccination, :vaccine]), "pfizer")
            ),
          }
        ],
        assignments: [
          %{
            column: 4,
            description: "not_same_vaccine",
            expression: false,
            target: [:booster_compatibilities, :pfizer],
          }
        ]
      },
      %{
        conditions: [
          %{
            column: 1,
            expression: quote(do:
              lt(@end_of_registration_window, @end_of_booster_delay)
            ),
          }
        ],
        assignments: [
          %{
            column: 4,
            description: "too_early",
            expression: false,
            target: [:booster_compatibilities, :pfizer],
          }
        ]
      },
      %{
        conditions: [
          %{
            column: 1,
            expression: quote(do:
              lt(@end_of_registration_window, @birthday_65)
            ),
          },
          %{
            column: 3,
            expression: quote(do: is_false(@high_risk)),
          }
        ],
        assignments: [
          %{
            column: 4,
            description: "too_young_not_high_risk",
            target: [:booster_compatibilities, :pfizer],
            expression: false
          }
        ]
      },
      %{
        conditions: [],
        assignments: [
          %{
            column: 4,
            description: "compatible",
            target: [:booster_compatibilities, :pfizer],
            expression: true
          }
        ]
      }
    ]
  },


  %{
    description: "PFIZER COMPATIBILITY",
    columns: [
      %{variable: :end_of_infection_delay},
      %{variable: [:previous_vaccination, :vaccine]},
      %{variable: [:booster_compatibilities, :pfizer]},
      %{variable: :end_of_registration_window},
      %{variable: :high_risk},
      %{type: "assignment", variable: [:vaccine_compatibilities, :pfizer, :compatible]},
      %{type: "assignment", variable: :end_of_delays_pfizer}
    ],
    branches: [
      %{
        conditions: [
          %{
            column: 3,
            expression: quote(do: lt(@end_of_registration_window, @birthday_12)),
          }
        ],
        assignments: [
          %{
            description: "younger_than_12",
            column: 5,
            target: [:vaccine_compatibilities, :pfizer, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 0,
            expression: quote(do: gt(@end_of_infection_delay, @end_of_registration_window)),
          }
        ],
        assignments: [
          %{
            description: "recently_infected",
            column: 5,
            target: [:vaccine_compatibilities, :pfizer, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 1,
            expression: quote(do: is_nil(var([:previous_vaccination, :vaccine]))),
          },
        ],
        assignments: [
          %{
            description: "not_booster_candidate",
            column: 5,
            target: [:vaccine_compatibilities, :pfizer, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 2,
            expression: quote(do: is_false(var([:booster_compatibilities, :pfizer]))),
          },
        ],
        assignments: [
          %{
            description: "incompatible_with_pfizer_booster",
            column: 5,
            target: [:vaccine_compatibilities, :pfizer, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 4,
            expression: quote(do: is_true(@high_risk)),
          },
        ],
        assignments: [
          %{
            description: "pfizer_booster",
            column: 5,
            target: [:vaccine_compatibilities, :pfizer, :compatible],
            expression: true
          },
          %{
            column: 6,
            target: :end_of_delays_pfizer,
            expression: quote(do: latest(@end_of_infection_delay, @end_of_booster_delay))
          }
        ],
      },
      %{
        assignments: [
          %{
            description: "pfizer_booster",
            column: 5,
            target: [:vaccine_compatibilities, :pfizer, :compatible],
            expression: true
          },
          %{
            column: 6,
            target: :end_of_delays_pfizer,
            expression: quote(do: latest(@end_of_infection_delay, @end_of_booster_delay, @birthday_65))
          }
        ],
      }
    ]
  },


    %{
      description: "ELIGIBILITY",
      columns: [
        %{variable: [:vaccine_compatibilities, :moderna, :compatible]},
        %{variable: [:vaccine_compatibilities, :pfizer, :compatible]},
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


    ##### PRIORITY ########################################################

    %{
      description: "MODERNA PRIORITY",
      columns: [
        %{variable: [:vaccine_compatibilities, :moderna, :compatible]},
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
              description: "not_compatible",
              column: 1,
              expression: -1
            }
          ]
        },
        %{
          assignments: [
            %{
              target: [:vaccine_compatibilities, :moderna, :priority],
              description: "all",
              column: 1,
              expression: 100
            }
          ]
        },
      ]
    },
    %{
      description: "PFIZER PRIORITIES",
      columns: [
        %{variable: [:vaccine_compatibilities, :pfizer, :compatible]},
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
              description: "not_compatible",
              column: 1,
              expression: -1
            }
          ]
        },
        %{
          assignments: [
            %{
              target: [:vaccine_compatibilities, :pfizer, :priority],
              description: "all",
              column: 1,
              expression: 100
            }
          ]
        },
      ]
    },

    ##### SEQUENCES ###########################################################


    %{
      description: "MODERNA SEQUENCE START",
      columns: [
        %{variable: [:vaccine_compatibilities, :moderna, :compatible]},
        %{variable: [:previous_vaccination, :vaccine]},
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
              expression: quote(do: is_not_nil(var([:previous_vaccination, :vaccine])))
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
              expression: 0
            },
            %{
              column: 6,
              target: [:injection_sequence, :moderna, :reference_date],
              expression: quote(do: latest(@check_date, @end_of_delays_moderna))
            },
            %{
              column: 7,
              target: [:injection_sequence, :moderna, :dose_type],
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
              expression: 0
            },
            %{
              column: 6,
              target: [:injection_sequence, :moderna, :reference_date],
              expression: quote(do: latest(@check_date, @end_of_delays_moderna))
            },
            %{
              column: 7,
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
              expression: quote(do: latest(@check_date, @end_of_delays_moderna))
            },
            %{
              column: 7,
              target: [:injection_sequence, :moderna, :dose_type],
              expression: "1"
            }
          ]
        }
      ]
    },
    %{
      description: "MODERNA ONEDOC PREVIOUS VACCINATION INFOS",
      columns: [
        %{variable: [:vaccine_compatibilities, :moderna, :compatible]},
        %{variable: [:previous_vaccination, :vaccine]},
        %{
          type: "assignment",
          variable: [
            :injection_sequence,
            :moderna,
            :onedoc,
            :previous_vaccination_vaccine
          ]
        },
        %{
          type: "assignment",
          variable: [
            :injection_sequence,
            :moderna,
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
                      var([:vaccine_compatibilities, :moderna, :compatible])
                    )
                )
            },
            %{
              column: 1,
              expression: quote(do: is_not_nil(var([:previous_vaccination, :vaccine])))
            }
          ],
          assignments: [
            %{
              target: [:injection_sequence, :moderna, :onedoc, :previous_vaccination_vaccine],
              column: 2,
              expression: quote(do: var([:previous_vaccination, :vaccine]))
            },
            %{
              target: [:injection_sequence, :moderna, :onedoc, :previous_vaccination_last_dose_date],
              column: 3,
              expression: quote(do: var([:previous_vaccination, :last_dose_date]))
            },
          ]
        }
      ]
    },
    %{
      description: "PFIZER SEQUENCE START",
      columns: [
        %{variable: [:vaccine_compatibilities, :pfizer, :compatible]},
        %{variable: [:previous_vaccination, :vaccine]},
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
              expression: quote(do: is_not_nil(var([:previous_vaccination, :vaccine])))
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
              expression: quote(do: latest(@check_date, @end_of_delays_pfizer))
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
              expression: 0
            },
            %{
              column: 6,
              target: [:injection_sequence, :pfizer, :reference_date],
              expression: quote(do: latest(@check_date, @end_of_delays_pfizer))
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
              expression: quote(do: latest(@check_date, @end_of_delays_pfizer))
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
        %{variable: [:previous_vaccination, :vaccine]},
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
              expression: quote(do: is_not_nil(var([:previous_vaccination, :vaccine])))
            }
          ],
          assignments: [
            %{
              target: [:injection_sequence, :pfizer, :onedoc, :previous_vaccination_vaccine],
              column: 2,
              expression: quote(do: var([:previous_vaccination, :vaccine]))
            },
            %{
              target: [:injection_sequence, :pfizer, :onedoc, :previous_vaccination_last_dose_date],
              column: 3,
              expression: quote(do: var([:previous_vaccination, :last_dose_date]))
            },
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
      description: "FLAG BOOSTER ONLY AFTER MODERNA OR PFIZER",
      columns: [
        %{variable: [:previous_vaccination, :vaccine]},
        %{type: "assignment", variable: [:flags, :booster_only_after_moderna_or_pfizer]}
      ],
      branches: [
        %{
          conditions: [
            %{expression: quote(do: is_nil(var([:previous_vaccination, :vaccine]))), column: 0},
          ]
        },
        %{
          conditions: [
            %{expression: quote(do: eq(var([:previous_vaccination, :vaccine]), "moderna")), column: 0},
          ]
        },
        %{
          conditions: [
            %{expression: quote(do: eq(var([:previous_vaccination, :vaccine]), "pfizer")), column: 0},
          ]
        },
        %{
          assignments: [
            %{
              column: 1,
              target: [:flags, :booster_only_after_moderna_or_pfizer],
              expression: true
            }
          ]
        }
      ]
    }
  ]
}
