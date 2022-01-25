defmodule VacEngine.Simulation.Job do
  @moduledoc false

  alias VacEngine.Simulation.Job
  alias VacEngine.Simulation.Stack

  defstruct error: nil, from: nil, stack_id: nil, result: nil

  def new(%Stack{id: id}) do
    %Job{stack_id: id, from: self()}
  end
end
