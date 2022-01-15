defmodule VacEngine.Simulation.InputEntry do
  @moduledoc false

  use Ecto.Schema

  alias VacEngine.Account.Workspace
  alias VacEngine.Simulation.Case

  schema "simulation_input_entries" do

    belongs_to(:workspace, Workspace)
    belongs_to(:case, Case)

    field(:key, :string)
    field(:value, :string)
  end

end
