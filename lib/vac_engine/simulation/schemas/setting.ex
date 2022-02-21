defmodule VacEngine.Simulation.Setting do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Simulation.Setting

  schema "simulation_settings" do
    timestamps(type: :utc_datetime)

    belongs_to(:blueprint, Blueprint)
    belongs_to(:workspace, Workspace)

    field(:env_now, :utc_datetime)
  end

  def to_map(%Setting{} = s) do
    %{
      env_now: s.env_now
    }
  end

  def inject_changeset(simulation_setting, params \\ %{}, ctx) do
    bp = ctx.bp_base

    simulation_setting
    |> cast(
      Map.merge(params, %{blueprint_id: bp.id, workspace_id: bp.workspace_id}),
      [:env_now, :blueprint_id, :workspace_id]
    )
  end
end
