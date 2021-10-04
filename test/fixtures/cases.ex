defmodule Fixtures.Cases do
  Module.register_attribute(__MODULE__, :case, accumulate: true)

  @case %{
    blueprint: :simple_test,
    input: %{aint: 80, bint: 10},
    output: %{bint: 81, cint: 12}
  }
  @case %{
    blueprint: :simple_test,
    input: %{aint: 240, bint: 10},
    output: %{cint: 241}
  }
  @case %{
    blueprint: :nested_test,
    input: %{
      obj_list: [
        %{child_int: 4, child_object: %{grand_child_int: 98}},
        %{child_int: 6, child_object: %{grand_child_int: 42}}
      ],
      int_list: [9, 43, 74]
    },
    output: %{
      map_list: [
        %{child_object: %{grand_child_int: 15}},
        %{child_int: 25},
        %{child_object: %{grand_child_int: 35}},
        %{child_int: 45}
      ],
      dnest: [%{dnest2: [%{dnest3: "nested"}]}],
      int_list: [54]
    }
  }

  def cases() do
    @case
  end
end
