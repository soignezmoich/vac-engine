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
    birthday_18: %{
      type: :date,
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
    end_of_delays_janssen: %{
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
        immuno_no_booster: %{type: :boolean, mapping: :out},
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
      branches: [] # INFECTION HAS NO EFFECT FOR GROUP 3 AND 5 (BL, GE, LI, SZ, ZG  AND  AR)
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
        %{type: "assignment", variable: :birthday_18}
      ],
      branches: [
        %{
          assignments: [
            %{
              target: :birthday_18,
              expression: quote(do: add_years(@birthdate, 18)),
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
    description: "IMMUNO CHECK",
    columns: [
      %{variable: :immuno},
      %{variable: :immuno_discussed},
      %{variable: :immuno_recommended},
      %{type: "assignment", variable: [:flags, :immuno_need_recommendation]},
      %{type: "assignment", variable: [:flags, :immuno_not_recommended]}
    ],
    branches: [
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
        ],
      },
      %{
        conditions: [
          %{expression: quote(do: is_true(@immuno)), column: 0},
          %{expression: quote(do: is_false(@immuno_recommended)), column: 2}
        ],
        assignments: [
          %{
            column: 4,
            target: [:flags, :immuno_not_recommended],
            expression: true
          }
        ],
      },
    ]
  },

  %{
    description: "AGE CHECK", # TODO add janssen, moderna special ages
    columns: [
      %{variable: :end_of_registration_window},
      %{type: "assignment", variable: [:flags, :under_12]},
      %{type: "assignment", variable: [:flags, :janssen_under_18]},
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
      %{variable: :immuno},
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
            column: 3,
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
            column: 3,
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
          }
        ],
        assignments: [
          %{
            description: "too_young",
            column: 3,
            target: [:booster_compatibilities, :moderna],
            expression: false
          }
        ]
      },
      %{
        conditions: [
          %{
            expression: quote(do: is_true(@immuno)),
            column: 2
          }
        ],
        assignments: [
          %{
            description: "no_booster_immuno",
            column: 3,
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
            column: 3,
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
      %{variable: [:flags, :immuno_need_recommendation]},
      %{variable: [:flags, :immuno_not_recommended]},
      %{variable: :rejects_mrna},
      %{variable: :end_of_infection_delay},
      %{variable: [:previous_vaccination, :vaccine]},
      %{variable: [:booster_compatibilities, :moderna]},
      %{variable: :end_of_registration_window},
      %{type: "assignment", variable: [:vaccine_compatibilities, :moderna, :compatible]},
      %{type: "assignment", variable: :end_of_delays_moderna}
    ],
    branches: [
      %{
        conditions: [
          %{
            column: 0,
            expression: quote(do: is_true(var([:flags, :immuno_need_recommendation])))
          },
        ],
        assignments: [
          %{
            description: "immuno_need_recommendation",
            column: 7,
            target: [:vaccine_compatibilities, :moderna, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 1,
            expression: quote(do: is_true(var([:flags, :immuno_not_recommended]))),
          },
        ],
        assignments: [
          %{
            description: "immuno_not_recommended",
            column: 7,
            target: [:vaccine_compatibilities, :moderna, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 2,
            expression: quote(do: is_true(@rejects_mrna)),
          },
        ],
        assignments: [
          %{
            description: "rejects_mrna",
            column: 7,
            target: [:vaccine_compatibilities, :moderna, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 4,
            expression: quote(do: is_not_nil(var([:previous_vaccination, :vaccine]))),
          },
          %{
            column: 5,
            expression: quote(do: is_false(var([:booster_compatibilities, :moderna]))),
          }
        ],
        assignments: [
          %{
            description: "incompatible_with_moderna_booster",
            column: 7,
            target: [:vaccine_compatibilities, :moderna, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 5,
            expression: quote(do: is_true(var([:booster_compatibilities, :moderna]))),
          }
        ],
        assignments: [
          %{
            description: "moderna_booster",
            column: 7,
            target: [:vaccine_compatibilities, :moderna, :compatible],
            expression: true
          },
          %{
            column: 8,
            target: :end_of_delays_moderna,
            expression: quote(do: latest(@end_of_booster_delay, @birthday_18))
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 6,
            expression: quote(do: lt(@end_of_registration_window, @birthday_18)),
          }
        ],
        assignments: [
          %{
            description: "younger_than_18",
            column: 7,
            target: [:vaccine_compatibilities, :moderna, :compatible],
            expression: false
          }
        ],
      },
      %{
        assignments: [
          %{
            description: "other",
            column: 7,
            target: [:vaccine_compatibilities, :moderna, :compatible],
            expression: true
          },
          %{
            column: 8,
            target: :end_of_delays_moderna,
            expression: quote(do: @birthday_18)
          }
        ],
      },
    ]
  },


  ##### PFIZER COMPATIBILITY #######################################################


  %{
    description: "PFIZER BOOSTER COMPATIBILITY",
    columns: [
      %{variable: [:previous_vaccination, :vaccine]},
      %{variable: :end_of_registration_window},
      %{variable: :immuno},
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
            column: 3,
            description: "not_same_vaccine",
            expression: false,
            target: [:booster_compatibilities, :pfizer],
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
            column: 3,
            description: "too_early",
            expression: false,
            target: [:booster_compatibilities, :pfizer],
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
          }
        ],
        assignments: [
          %{
            description: "too_young",
            column: 3,
            target: [:booster_compatibilities, :pfizer],
            expression: false
          }
        ]
      },
      %{
        conditions: [
          %{
            expression: quote(do: is_true(@immuno)),
            column: 2
          }
        ],
        assignments: [
          %{
            description: "no_booster_immuno",
            column: 3,
            target: [:booster_compatibilities, :pfizer],
            expression: false
          }
        ]
      },
      %{
        conditions: [],
        assignments: [
          %{
            description: "compatible",
            column: 3,
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
      %{variable: [:flags, :immuno_need_recommendation]},
      %{variable: [:flags, :immuno_not_recommended]},
      %{variable: :rejects_mrna},
      %{variable: :end_of_infection_delay},
      %{variable: [:previous_vaccination, :vaccine]},
      %{variable: [:booster_compatibilities, :pfizer]},
      %{variable: :check_date},
      %{type: "assignment", variable: [:vaccine_compatibilities, :pfizer, :compatible]},
      %{type: "assignment", variable: :end_of_delays_pfizer}
    ],
    branches: [
      %{
        conditions: [
          %{
            column: 0,
            expression: quote(do: is_true(var([:flags, :immuno_need_recommendation])))
          },
        ],
        assignments: [
          %{
            description: "immuno_need_recommendation",
            column: 7,
            target: [:vaccine_compatibilities, :pfizer, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 1,
            expression: quote(do: is_true(var([:flags, :immuno_not_recommended]))),
          },
        ],
        assignments: [
          %{
            description: "immuno_not_recommended",
            column: 7,
            target: [:vaccine_compatibilities, :pfizer, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 6,
            expression: quote(do: lt(@check_date, @birthday_12)),
          }
        ],
        assignments: [
          %{
            description: "younger_than_12",
            column: 7,
            target: [:vaccine_compatibilities, :pfizer, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 2,
            expression: quote(do: is_true(@rejects_mrna)),
          },
        ],
        assignments: [
          %{
            description: "rejects_mrna",
            column: 7,
            target: [:vaccine_compatibilities, :pfizer, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 4,
            expression: quote(do: is_not_nil(var([:previous_vaccination, :vaccine]))),
          },
          %{
            column: 5,
            expression: quote(do: is_false(var([:booster_compatibilities, :pfizer]))),
          }
        ],
        assignments: [
          %{
            description: "incompatible_with_pfizer_booster",
            column: 7,
            target: [:vaccine_compatibilities, :pfizer, :compatible],
            expression: false
          }
        ],
      },
      %{
        conditions: [
          %{
            column: 5,
            expression: quote(do: is_true(var([:booster_compatibilities, :pfizer]))),
          }
        ],
        assignments: [
          %{
            description: "pfizer_booster",
            column: 7,
            target: [:vaccine_compatibilities, :pfizer, :compatible],
            expression: true
          },
          %{
            column: 8,
            target: :end_of_delays_pfizer,
            expression: quote(do: latest(@end_of_booster_delay, @birthday_18))
          }
        ],
      },
      %{
        assignments: [
          %{
            description: "other",
            column: 7,
            target: [:vaccine_compatibilities, :pfizer, :compatible],
            expression: true
          },
          %{
            column: 8,
            target: :end_of_delays_pfizer,
            expression: quote(do: @birthday_12)
          }
        ],
      },
    ]
  },



  %{
      description: "JANSSEN COMPATIBILITY",
      columns: [
        %{variable: [:previous_vaccination, :vaccine]},
        %{variable: :rejects_mrna},
        %{variable: :immuno},
        %{variable: :pregnant},
        %{variable: :end_of_registration_window},
        %{
          type: "assignment",
          variable: [:vaccine_compatibilities, :janssen, :compatible]
        },
        %{type: "assignment", variable: :end_of_delays_janssen},
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
            %{expression: quote(do: lt(@end_of_registration_window, @birthday_18)), column: 4}
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
            },
            %{
              target: :end_of_delays_janssen,
              column: 6,
              expression: quote(do: @birthday_18),
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
              description: "not_compatible",
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
              description: "all",
              column: 1,
              expression: 100
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
            :previous_vaccination_doses_count
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
              target: [:injection_sequence, :moderna, :onedoc, :previous_vaccination_doses_count],
              column: 3,
              expression: quote(do: var([:previous_vaccination, :doses_count]))
            },
            %{
              target: [:injection_sequence, :moderna, :onedoc, :previous_vaccination_last_dose_date],
              column: 4,
              expression: quote(do: var([:previous_vaccination, :last_dose_date]))
            },
          ]
        }
      ]
    },

    %{
      description: "MODERNA SEQUENCE END",
      columns: [
        %{variable: [:vaccine_compatibilities, :moderna, :compatible]},
        %{variable: [:previous_vaccination, :vaccine]},
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
              expression: quote(do: is_nil(var([:previous_vaccination, :vaccine])))
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
              column: 3,
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
              column: 4,
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
              column: 5,
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
              column: 7,
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
        %{variable: [:previous_vaccination, :vaccine]},
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
              expression: quote(do: is_nil(var([:previous_vaccination, :vaccine])))
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
            }
          ],
          assignments: [
            %{
              column: 1,
              target: [:injection_sequence, :janssen, :vaccine],
              expression: "janssen"
            },
            %{
              column: 2,
              target: [:injection_sequence, :janssen, :delay_min],
              expression: 0
            },
            %{
              column: 4,
              target: [:injection_sequence, :janssen, :reference_date],
              expression: quote(do: latest(@check_date, @end_of_delays_janssen))
            },
            %{
              column: 5,
              target: [:injection_sequence, :janssen, :dose_type],
              expression: "1"
            }
          ]
        },
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
      description: "FLAG IMMUNO NO BOOSTER",
      columns: [
        %{variable: :immuno},
        %{variable: :previous_vaccination},
        %{type: "assignment", variable: [:flags, :immuno_no_booster]}
      ],
      branches: [
        %{
          conditions: [
            %{expression: quote(do: is_true(@immuno)), column: 0},
            %{
              expression: quote(do: is_not_nil(@previous_vaccination)),
              column: 1
            }
          ],
          assignments: [
            %{
              column: 2,
              target: [:flags, :immuno_no_booster],
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
      description: "FLAG REJECTS MRNA IMMUNO",
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
      description: "FLAG REJECTS MRNA UNDER 18",
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
