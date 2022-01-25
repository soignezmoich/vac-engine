defmodule VacEngine.Simulation.Result do
  @moduledoc false

  defstruct run_error: nil,
            input: nil,
            output: nil,
            entries: nil,
            has_error?: false
end
