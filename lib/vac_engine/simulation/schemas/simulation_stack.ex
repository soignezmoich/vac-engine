defmodule VacEngine.Simulation.Stack do
  @moduledoc false

  use Ecto.Schema

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Simulation.Layer

  schema "simulation_stacks" do
    belongs_to(:blueprint, Blueprint)
    belongs_to(:workspace, Workspace)

    has_many(:layers, Layer)

    field(:active, :boolean) # set to false if you don't want the case stack to be run
  end

end
