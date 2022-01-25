defmodule VacEngine.Simulation.Result do
  @moduledoc false

  alias VacEngine.Simulation.Job
  alias VacEngine.Processor.Blueprint

  defstruct run_error: nil,
            input: nil,
            output: nil,
            entries: nil,
            has_error?: false
end
