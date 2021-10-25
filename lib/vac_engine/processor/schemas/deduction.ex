defmodule VacEngine.Processor.Deduction do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.EctoHelpers
  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Deduction
  import VacEngine.EnumHelpers

  schema "deductions" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)

    has_many(:branches, Branch, on_replace: :delete)
    has_many(:columns, Column, on_replace: :delete)

    field(:position, :integer)
    field(:description, :string)
  end

  def changeset(data, attrs, ctx) do
    attrs =
      attrs
      |> EctoHelpers.set_positions(:branches)
      |> EctoHelpers.set_positions(:columns)

    data
    |> cast(attrs, [:description, :position])
    |> change(blueprint_id: ctx.blueprint_id, workspace_id: ctx.workspace_id)
    |> cast_assoc(:branches, with: {Branch, :changeset, [ctx]})
    |> cast_assoc(:columns, with: {Column, :changeset, [ctx]})
    |> validate_required([])
  end

  def to_map(%Deduction{} = d) do
    %{
      description: d.description,
      columns: Enum.map(d.columns, &Column.to_map/1),
      branches: Enum.map(d.branches, &Branch.to_map/1)
    }
    |> compact
  end
end
