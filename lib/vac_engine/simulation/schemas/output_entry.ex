defmodule VacEngine.Simulation.OutputEntry do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Simulation.Case

  schema "simulation_output_entries" do
    belongs_to(:workspace, Workspace)
    belongs_to(:case, Case)

    field(:key, :string)
    field(:expected, :string)
  end

  def changeset(output_entry, attrs) do
    output_entry
    |> cast(attrs, [:expected])
    |> validate_required([:workspace, :case, :key, :expected])
  end
end
