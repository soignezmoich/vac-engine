defmodule VacEngine.Simulation.Runners do
  @moduledoc false

  alias VacEngine.Simulation.Runner

  def queue_job(job) do
    Runner.queue(job)
  end

end
