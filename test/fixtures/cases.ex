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
        dnest: %{dnest2: [%{dnest3: "nested"}]},
        int_list: [1, 2, 3]
      }
    }
  end

  cas(:sig_test) do
    %{
      input: %{age: "hello"},
      error: "value hello is invalid for age"
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
          birthdate: "1971-03-04",
          healthcare_worker: true
        }
        |> default(),
      output: %{
        vaccine_compatibilities: %{
          moderna: %{compatible: true, priority: 3},
          pfizer: %{compatible: true, priority: 3},
          janssen: %{compatible: false, priority: -1}
        },
        injection_sequence: %{
          moderna: %{
            delay_min: 0,
            next_injections: %{
              moderna: %{
                delay_max: 35,
                delay_min: 28,
                vaccine: "moderna",
                dose_type: "2"
              }
            },
            reference_date: now(),
            vaccine: "moderna",
            dose_type: "1"
          },
          pfizer: %{
            delay_min: 0,
            next_injections: %{
              pfizer: %{
                delay_max: 35,
                delay_min: 28,
                vaccine: "pfizer",
                dose_type: "2"
              }
            },
            reference_date: now(),
            vaccine: "pfizer",
            dose_type: "1"
          }
        },
        registrable_if_dose_within: 30
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
        vaccine_compatibilities: %{
          moderna: %{compatible: true, priority: 3},
          pfizer: %{compatible: true, priority: 3},
          janssen: %{compatible: false, priority: -1}
        },
        injection_sequence: %{
          moderna: %{
            delay_min: 28,
            reference_date: "2020-05-04",
            vaccine: "moderna",
            dose_type: "1"
          },
          pfizer: %{
            delay_min: 28,
            reference_date: "2020-05-04",
            vaccine: "pfizer",
            dose_type: "1"
          }
        },
        registrable_if_dose_within: 30
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
        vaccine_compatibilities: %{
          moderna: %{compatible: false, priority: -1},
          pfizer: %{compatible: false, priority: -1},
          janssen: %{compatible: true, priority: 1}
        },
        registrable_if_dose_within: 30,
        injection_sequence: %{
          janssen: %{
            delay_min: 0,
            reference_date: now(),
            vaccine: "janssen",
            dose_type: "1"
          }
        }
      }
    }
  end
end
