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

  schema "simulation_layers" do
    belongs_to(:blueprint, Blueprint)
    belongs_to(:workspace, Workspace)
    belongs_to(:stack, Stack)
    belongs_to(:case, Case)

    field(:position, :integer)
  end

  # Inject layer with a reference to an existing case (no full case).
  def nested_changeset(layer, %{case: %{id: case_id}} = attrs, ctx) do
    referenced_case = Repo.get(Case, case_id)

    layer
    |> cast(attrs, [:position])
    |> change(workspace_id: ctx.workspace_id, blueprint_id: ctx.blueprint_id)
    |> put_assoc(:case, referenced_case)
  end

  # Inject layer with a full case description so that a new case is created.
  def nested_changeset(data, attrs, ctx) do
    data
    |> cast(attrs, [:position])
    |> change(workspace_id: ctx.workspace_id, blueprint_id: ctx.blueprint_id)
    |> cast_assoc(:case, with: {Case, :nested_changeset, [ctx]})
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
