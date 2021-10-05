defmodule Fixtures.Cases do
  Module.register_attribute(__MODULE__, :case, accumulate: true)

  import Fixtures.Helpers

  @case %{
    blueprint: :simple_test,
    input: %{aint: 80, bint: 10},
    output: %{bint: 81, cint: 12}
  }
  @case %{
    blueprint: :simple_test,
    input: %{aint: 240, bint: 10},
    output: %{cint: 241, bint: 10}
  }
  @case %{
    blueprint: :nested_test,
    input: %{
      obj_list: [
        %{child_int: 4, child_object: %{grand_child_int: 98}},
        %{child_int: 6}
      ],
      int_list: [9, 43, 74]
    },
    output: %{
      map_list: [
        %{
          child_object: %{
            grand_child_int: 15,
            grand_child_map: %{grand_grand_child_ints: [1, 2, 3]}
          }
        },
        %{
          child_int: 25
        },
        %{child_object: %{grand_child_int: 35}},
        %{child_int: 45}
      ],
      dnest: [%{dnest2: [%{dnest3: "nested"}]}],
      int_list: [1, 2, 3]
    }
  }

  @injection_sequence [
    %{
      delay_min: 0,
      next_injection: %{delay_max: 35, delay_min: 28, vaccine: "moderna"},
      reference_date: now(),
      vaccine: "moderna"
    },
    %{
      delay_min: 0,
      next_injection: %{delay_max: 35, delay_min: 28, vaccine: "pfizer"},
      reference_date: now(),
      vaccine: "pfizer"
    }
  ]

  @case %{
    blueprint: :ruleset0,
    input: %{
      birthdate: "2018-03-04"
    },
    output: %{
      age: age("2018-03-04"),
      vaccine_compatibilities: %{
        moderna: %{compatible: false, priority: -1},
        pfizer: %{compatible: false, priority: -1}
      }
    }
  }

  @case %{
    blueprint: :ruleset0,
    input: %{
      birthdate: "1902-03-04"
    },
    output: %{
      age: age("1902-03-04"),
      vaccine_compatibilities: %{
        moderna: %{compatible: true, priority: 1},
        pfizer: %{compatible: true, priority: 1}
      },
      injection_sequence: @injection_sequence
    }
  }

  @case %{
    blueprint: :ruleset0,
    input: %{
      birthdate: "1982-03-04"
    },
    output: %{
      age: age("1982-03-04"),
      vaccine_compatibilities: %{
        moderna: %{compatible: true, priority: 7},
        pfizer: %{compatible: true, priority: 7}
      },
      injection_sequence: @injection_sequence
    }
  }

  @case %{
    blueprint: :ruleset0,
    input: %{
      birthdate: "1940-03-04"
    },
    output: %{
      age: age("1940-03-04"),
      vaccine_compatibilities: %{
        moderna: %{compatible: true, priority: 1},
        pfizer: %{compatible: true, priority: 1}
      },
      injection_sequence: @injection_sequence
    }
  }

  @case %{
    blueprint: :ruleset0,
    input: %{
      birthdate: "1955-03-04"
    },
    output: %{
      age: age("1955-03-04"),
      vaccine_compatibilities: %{
        moderna: %{compatible: true, priority: 2},
        pfizer: %{compatible: true, priority: 2}
      },
      injection_sequence: @injection_sequence
    }
  }

  @case %{
    blueprint: :ruleset0,
    input: %{
      birthdate: "1960-03-04"
    },
    output: %{
      age: age("1960-03-04"),
      vaccine_compatibilities: %{
        moderna: %{compatible: true, priority: 3},
        pfizer: %{compatible: true, priority: 3}
      },
      injection_sequence: @injection_sequence
    }
  }

  @case %{
    blueprint: :ruleset0,
    input: %{
      birthdate: "1971-03-04",
      healthcare_worker: true
    },
    output: %{
      age: age("1971-03-04"),
      vaccine_compatibilities: %{
        moderna: %{compatible: true, priority: 4},
        pfizer: %{compatible: true, priority: 4}
      },
      injection_sequence: @injection_sequence
    }
  }

  @case %{
    blueprint: :ruleset0,
    input: %{
      birthdate: "1970-03-04",
      high_risk_contact: true,
      infection_date: "2020-05-04"
    },
    output: %{
      age: age("1970-03-04"),
      vaccine_compatibilities: %{
        moderna: %{compatible: true, priority: 5},
        pfizer: %{compatible: true, priority: 5}
      },
      flags: %{infection: true},
      injection_sequence: [
        %{
          delay_min: 28,
          reference_date: "2020-05-04",
          vaccine: "moderna"
        },
        %{
          delay_min: 28,
          reference_date: "2020-05-04",
          vaccine: "pfizer"
        }
      ]
    }
  }

  def cases() do
    @case
  end
end
