defmodule VacEngine.Simulation.Setting do
  @moduledoc false

  use Ecto.Schema

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint

  schema "simulation_settings" do
    timestamps(type: :utc_datetime)

    belongs_to(:blueprint, Blueprint)
    belongs_to(:workspace, Workspace)

    field(:day_of_simulation, :naive_datetime)
  end

end
