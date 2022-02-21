defmodule VacEngine.Simulation.InputEntry do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.InputEntry

  schema "simulation_input_entries" do
    belongs_to(:workspace, Workspace)
    belongs_to(:case, Case)

    field(:key, :string)
    field(:value, :string)
  end

  def changeset(input_entry, attrs) do
    input_entry
    |> cast(attrs, [:value])
    |> validate_required([:workspace, :case, :key, :value])
  end

  def nested_changeset(data, attrs, ctx) do
    data
    |> cast(attrs, [:key, :value])
    |> change(workspace_id: ctx.workspace_id)
  end

  def to_map(%InputEntry{} = ie) do
    %{
      key: ie.key,
      value: ie.value
    }
  end
end
