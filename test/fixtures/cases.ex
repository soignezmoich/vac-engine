defmodule Fixtures.Cases do
  import Fixtures.Helpers
  use Fixtures.Helpers.Cases

  cas(:simple_test) do
    %{
      input: %{aint: 80, bint: 10, cint: 4},
      output: %{bint: 81, cint: 12}
    }
  end

  cas(:simple_test) do
    %{
      input: %{aint: 240, bint: 10, cint: 4},
      output: %{cint: 241, bint: 10}
    }
  end

  cas(:simple_test) do
    %{
      input: %{aint: 80, bint: 10},
      error: "variable cint is required"
    }
  end

  cas(:nested_test) do
    %{
      input: %{
        obj_list: [
          %{child_int: 6}
        ],
        int_list: [9, 43, 74]
      },
      error: "variable enum_string is required"
    }
  end

  cas(:nested_test) do
    %{
      input: %{
        enum_string: "aa"
      },
      error: "value aa not found in enum v1,v2"
    }
  end

  cas(:nested_test) do
    %{
      input: %{
        enum_string: "v1",
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
              grand_child_map: %{grand_grand_child_ints: [1, 2, 3, 42]}
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
  end

  def injection_sequence() do
    %{
      moderna: %{
        delay_min: 0,
        next_injections: %{
          moderna: %{delay_max: 35, delay_min: 28, vaccine: "moderna"}
        },
        reference_date: now(),
        vaccine: "moderna"
      },
      pfizer: %{
        delay_min: 0,
        next_injections: %{
          pfizer: %{delay_max: 35, delay_min: 28, vaccine: "pfizer"}
        },
        reference_date: now(),
        vaccine: "pfizer"
      }
    }
  end

  def default(input) do
    Map.merge(
      %{
        gender: "m",
        pregnant: "no",
        high_risk: false,
        immuno: false,
        immuno_discussed: false,
        immuno_recommended: false,
        healthcare_worker: false,
        high_risk_contact: false,
        immuno_contact: false,
        community_facility: false,
        vaccine_allergy: false,
        rejects_mrna: false
      },
      input
    )
  end

  cas(:ruleset0) do
    %{
      input:
        %{
          birthdate: "2018-03-04"
        }
        |> default(),
      output: %{
        age: age("2018-03-04"),
        vaccine_compatibilities: %{
          moderna: %{compatible: false, priority: -1},
          pfizer: %{compatible: false, priority: -1},
          janssen: %{compatible: false, priority: -1}
        }
      }
    }
  end

  cas(:ruleset0) do
    %{
      input:
        %{
          birthdate: "1902-03-04"
        }
        |> default(),
      output: %{
        age: age("1902-03-04"),
        vaccine_compatibilities: %{
          moderna: %{compatible: true, priority: 1},
          pfizer: %{compatible: true, priority: 1},
          janssen: %{compatible: false, priority: -1}
        },
        injection_sequence: injection_sequence()
      }
    }
  end

  cas(:ruleset0) do
    %{
      input:
        %{
          birthdate: "1982-03-04"
        }
        |> default(),
      output: %{
        age: age("1982-03-04"),
        vaccine_compatibilities: %{
          moderna: %{compatible: true, priority: 7},
          pfizer: %{compatible: true, priority: 7},
          janssen: %{compatible: false, priority: -1}
        },
        injection_sequence: injection_sequence()
      }
    }
  end

  cas(:ruleset0) do
    %{
      input:
        %{
          birthdate: "1940-03-04"
        }
        |> default(),
      output: %{
        age: age("1940-03-04"),
        vaccine_compatibilities: %{
          moderna: %{compatible: true, priority: 1},
          pfizer: %{compatible: true, priority: 1},
          janssen: %{compatible: false, priority: -1}
        },
        injection_sequence: injection_sequence()
      }
    }
  end

  cas(:ruleset0) do
    %{
      input:
        %{
          birthdate: "1955-03-04"
        }
        |> default(),
      output: %{
        age: age("1955-03-04"),
        vaccine_compatibilities: %{
          moderna: %{compatible: true, priority: 2},
          pfizer: %{compatible: true, priority: 2},
          janssen: %{compatible: false, priority: -1}
        },
        injection_sequence: injection_sequence()
      }
    }
  end

  cas(:ruleset0) do
    %{
      input:
        %{
          birthdate: "1960-03-04"
        }
        |> default(),
      output: %{
        age: age("1960-03-04"),
        vaccine_compatibilities: %{
          moderna: %{compatible: true, priority: 3},
          pfizer: %{compatible: true, priority: 3},
          janssen: %{compatible: false, priority: -1}
        },
        injection_sequence: injection_sequence()
      }
    }
  end

  cas(:ruleset0) do
    %{
      input:
        %{
          birthdate: "1971-03-04",
          healthcare_worker: true
        }
        |> default(),
      output: %{
        age: age("1971-03-04"),
        vaccine_compatibilities: %{
          moderna: %{compatible: true, priority: 4},
          pfizer: %{compatible: true, priority: 4},
          janssen: %{compatible: false, priority: -1}
        },
        injection_sequence: injection_sequence()
      }
    }
  end

  cas(:ruleset0) do
    %{
      input:
        %{
          birthdate: "1970-03-04",
          high_risk_contact: true,
          infection_date: "2020-05-04"
        }
        |> default(),
      output: %{
        age: age("1970-03-04"),
        vaccine_compatibilities: %{
          moderna: %{compatible: true, priority: 5},
          pfizer: %{compatible: true, priority: 5},
          janssen: %{compatible: false, priority: -1}
        },
        flags: %{infection: true},
        injection_sequence: %{
          moderna: %{
            delay_min: 28,
            reference_date: "2020-05-04",
            vaccine: "moderna"
          },
          pfizer: %{
            delay_min: 28,
            reference_date: "2020-05-04",
            vaccine: "pfizer"
          }
        }
      }
    }
  end

  cas(:ruleset0) do
    %{
      input:
        %{
          birthdate: "1970-03-04",
          high_risk_contact: true,
          rejects_mrna: true
        }
        |> default(),
      output: %{
        age: age("1970-03-04"),
        vaccine_compatibilities: %{
          moderna: %{compatible: false, priority: 5},
          pfizer: %{compatible: false, priority: 5},
          janssen: %{compatible: true, priority: 5}
        }
      }
    }
  end
end
