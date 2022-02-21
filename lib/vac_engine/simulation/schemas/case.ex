defmodule VacEngine.Simulation.Case do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Simulation.Case
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

    field(:expected_result, Ecto.Enum, values: ~w(ignore success error)a)
    field(:expected_error, :string)
  end

  def changeset(data, attrs \\ %{}) do
    data
    |> cast(attrs, [:name, :description, :env_now])
    |> validate_required([:name, :workspace_id])
  end

  def nested_changeset(data, attrs, ctx) do
    data
    |> cast(attrs, [
      :name,
      :description,
      :env_now,
      :runnable,
      :expected_result,
      :expected_error
    ])
    |> change(workspace_id: ctx.workspace_id)
    |> cast_assoc(:input_entries, with: {InputEntry, :nested_changeset, [ctx]})
    |> cast_assoc(:output_entries, with: {OutputEntry, :nested_changeset, [ctx]})
  end

  def to_map(%Case{} = c) do
    %{
      name: c.name,
      description: c.description,
      env_now: c.env_now,
      runnable: c.runnable,
      input_entries: Enum.map(c.input_entries, &InputEntry.to_map/1),
      output_entries: Enum.map(c.output_entries, &OutputEntry.to_map/1)
    }
  end
end
