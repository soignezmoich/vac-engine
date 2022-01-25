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

    has_many(:input_entries, InputEntry)
    has_many(:output_entries, OutputEntry)
    has_many(:layers, Layer)

    field(:name, :string)
    field(:description, :string)
    field(:env_now, :utc_datetime)
    field(:runnable, :boolean)
  end

  def changeset(data, attrs \\ %{}) do
    data
    |> cast(attrs, [:name, :description, :env_now])
    |> validate_required([:name, :workspace_id])
  end
end
