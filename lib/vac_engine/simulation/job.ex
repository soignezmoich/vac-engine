defmodule VacEngine.Simulation.Job do
  @moduledoc false

  alias VacEngine.Simulation.Job
  alias VacEngine.Simulation.Stack

  defstruct error: nil, publish_on: nil, stack_id: nil, result: nil

  def new(%Stack{id: id, blueprint_id: blueprint_id}) do
    %Job{stack_id: id, publish_on: "blueprint:#{blueprint_id}"}
  end
end
