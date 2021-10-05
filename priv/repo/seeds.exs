alias VacEngine.Account
alias VacEngine.Processor
alias VacEngine.Processor.Blueprint

blueprint = %{
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
            %{
              target: :eligible,
              expression: false
            }
          ]
        },
        %{
          conditions: [],
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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
          assignements: [
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

VacEngine.Repo.transaction(fn ->
  {:ok, user} =
    Account.create_user(%{
      "name" => "Default Admin",
      "email" => "admin@admin.com",
      "password" => "12341234"
    })

  {:ok, _role} = Account.grant_permission(user.role, [:global, :users, :write])

  {:ok, _role} =
    Account.grant_permission(user.role, [:global, :workspaces, :write])

  {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

  {:ok, blueprint} =
    Processor.create_blueprint(
      workspace,
      blueprint
    )
end)
