defmodule VacEngine.Simulation.Layer do
  @moduledoc false

  use Ecto.Schema

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Stack

  schema "simulation_layers" do
    belongs_to(:blueprint, Blueprint)
    belongs_to(:workspace, Workspace)
    belongs_to(:stack, Stack)
    belongs_to(:case, Case)

    field(:position, :integer)
  end
end