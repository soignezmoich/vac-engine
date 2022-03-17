defmodule VacEngine.Simulation.Layer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Repo
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.Stack
  import VacEngine.EctoHelpers

  schema "simulation_layers" do
    belongs_to(:blueprint, Blueprint)
    belongs_to(:workspace, Workspace)
    belongs_to(:stack, Stack)
    belongs_to(:case, Case)

    field(:position, :integer)
  end

  # Inject layer with a reference to an existing case (no full case).
  def nested_changeset(layer, %{case: %{id: case_id}} = attrs, ctx) do
    layer
    |> cast(attrs, [:position])
    |> change(workspace_id: ctx.workspace_id, blueprint_id: ctx.blueprint_id)
    |> prepare_changes(fn changeset ->
      referenced_case = Repo.get(Case, case_id)

      changeset
      |> put_assoc(:case, referenced_case)
    end)
  end

  # Inject layer with a full case description so that a new case is created.
  def nested_changeset(data, attrs, ctx) do
    data
    |> cast(attrs, [:position])
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

  # If the case is present, create the full case map.
  def to_map(%Layer{case: %Case{} = kase}) do
    %{case: Case.to_map(kase)}
  end

  # If case is not present (preloaded), make a reference using
  # the case id.
  def to_map(%Layer{case_id: case_id}) do
    %{case: %{id: case_id}}
  end
end
