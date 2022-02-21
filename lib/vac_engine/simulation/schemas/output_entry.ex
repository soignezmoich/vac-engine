defmodule VacEngine.Simulation.OutputEntry do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.OutputEntry

  schema "simulation_output_entries" do
    belongs_to(:workspace, Workspace)
    belongs_to(:case, Case)

    field(:key, :string)
    field(:expected, :string)
    field(:forbid, :boolean)
  end

  def nested_changeset(data, attrs, ctx) do
    data
    |> cast(attrs, [:key, :expected, :forbid])
    |> change(workspace_id: ctx.workspace_id)
  end

  def changeset(output_entry, attrs) do
    output_entry
    |> cast(attrs, [:expected])
    |> validate_required([:workspace, :case, :key, :expected])
  end

  def to_map(%OutputEntry{} = oe) do
    %{
      key: oe.key,
      expected: oe.expected,
      forbid: oe.forbid
    }
  end
end
