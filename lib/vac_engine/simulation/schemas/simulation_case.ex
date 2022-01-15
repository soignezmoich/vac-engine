defmodule VacEngine.Simulation.Case do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.InputEntry
  alias VacEngine.Simulation.OutputEntry

  schema "simulation_cases" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)

    has_many(:input_entry, InputEntry)
    has_many(:output_entry, OutputEntry)
    has_many(:layer, Layer)

    field(:name, :string)
    field(:description, :string)
    field(:simulated_time, :naive_datetime)
    field(:runnable, :boolean)
  end

  def changeset(data, attrs \\ %{}) do
    data
    |> cast(attrs, [:workspace_id, :name, :description, :simulated_time])
    |> validate_required([:workspace_id])
  end

end
