defmodule VacEngine.Simulation.Layer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
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

  def nested_changeset(data, attrs, ctx) do
    data
    |> cast(attrs, [
      :position
    ])
    |> change(workspace_id: ctx.workspace_id, blueprint_id: ctx.blueprint_id)
    |> cast_assoc(:case, with: {Case, :nested_changeset, [ctx]})
  end

  def to_map(%Layer{} = l) do
    kase =
      case l.case do
        %Case{} -> Case.to_map(l.case)
        _ -> nil
      end

    %{
      case: kase,
      case_id: l.case_id
    }
  end
end
