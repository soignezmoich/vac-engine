defmodule VacEngine.Simulation.OutputEntry do
  @moduledoc false

  use Ecto.Schema

  alias VacEngine.Account.Workspace
  alias VacEngine.Simulation.Case

  schema "simulation_output_entries" do
    belongs_to(:workspace, Workspace)
    belongs_to(:case, Case)

    field(:key, :string)
    # if null, the output is forbidden # TODO maybe explicit boolean
    field(:value, :string)
  end
end
