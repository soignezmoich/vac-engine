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

  cas(:sig_test) do
    %{
      input: %{age: nil},
      output: %{}
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

  cas(:nil_test) do
    %{
      input: %{},
      output: %{b0: 20}
    }
  end

  cas(:nil_test) do
    %{
      input: %{a0: false},
      output: %{b0: 20}
    }
  end

  cas(:nil_test) do
    %{
      input: %{a0: true},
      output: %{b0: 10}
    }
  end

  cas(:empty_test) do
    %{
      input: %{},
      output: %{}
    }
  end
end
