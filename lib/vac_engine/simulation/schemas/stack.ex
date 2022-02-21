defmodule VacEngine.Simulation.Stack do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  import VacEngine.EctoHelpers
  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.Stack

  schema "simulation_stacks" do
    belongs_to(:blueprint, Blueprint)
    belongs_to(:workspace, Workspace)

    has_many(:layers, Layer)

    has_one(:setting, through: [:blueprint, :simulation_setting])

    # set to false if you don't want the case stack to be run
    field(:active, :boolean)
  end

  def nested_changeset(data, attrs, ctx) do
    attrs =
      attrs
      |> set_positions(:layers)

    data
    |> cast(attrs, [
      :active
    ])
    |> change(workspace_id: ctx.workspace_id, blueprint_id: ctx.blueprint_id)
    |> cast_assoc(:layers, with: {Layer, :nested_changeset, [ctx]})
  end

  def to_map(%Stack{} = s) do
    %{
      layers: Enum.map(s.layers, &Layer.to_map/1)
    }
  end
end
