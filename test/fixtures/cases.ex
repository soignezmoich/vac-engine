defmodule Fixtures.Cases do
  Module.register_attribute(__MODULE__, :case, accumulate: true)

  #@case %{
  #  blueprint: :test,
  #  input: %{age: 85, immuno_suppressed: false, birthdate: "1980"},
  #  output: %{priority: 1}
  #}
  @case %{
   blueprint: :test,
   input: %{aint: 80, bint: 10},
   output: %{aint: 81, cint: 12, bint: 10}
  }
  @case %{
   blueprint: :test,
   input: %{aint: 210, bint: 10},
   output: %{aint: 211, bint: 10}
  }

  def cases() do
    @case
  end
end
