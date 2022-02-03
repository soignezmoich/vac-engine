defmodule Fixtures.Simulations do
  import Fixtures.Helpers
  use Fixtures.Helpers.Simulations

  sim(:test_all) do
    %{
      input: %{
        "aint" => 80,
        "bint" => 10,
        "cint" => 4
      },
      result: %{
        "bint" => %{actual: 81, match?: false},
        "aint" => %{actual: nil},
        "cint" => %{actual: 12, match?: true}
      }
    }
  end
end
