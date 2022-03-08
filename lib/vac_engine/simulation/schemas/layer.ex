defmodule VacEngine.Simulation.Layer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Stack
  import VacEngine.EctoHelpers

  schema "simulation_layers" do
    belongs_to(:blueprint, Blueprint)
    belongs_to(:workspace, Workspace)
    belongs_to(:stack, Stack)
    belongs_to(:case, Case)

    field(:position, :integer)
  end

  def nested_changeset(data, attrs, ctx) do
    data
    |> cast(attrs, [
      :position
    ])
    |> change(workspace_id: ctx.workspace_id, blueprint_id: ctx.blueprint_id)
    |> cast_assoc(:case, with: {Case, :nested_changeset, [ctx]})
  end

  def changeset(data, attrs \\ %{}) do
    data
    |> cast(attrs, [
      :position
    ])
    |> prepare_changes(fn changeset ->
      stack_id = get_field(changeset, :stack_id)
      shift_position(changeset, :stack_id, stack_id)
    end)
  end
end
