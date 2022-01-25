defmodule VacEngine.Simulation.InputEntry do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Simulation.Case

  schema "simulation_input_entries" do
    belongs_to(:workspace, Workspace)
    belongs_to(:case, Case)

    field(:key, :string)
    field(:value, :string)
  end

  def changeset(input_entry, attrs) do
    input_entry
    |> cast(attrs, [:value])
    |> validate_required([:workspace, :case, :key, :value])
  end
end
