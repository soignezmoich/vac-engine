defmodule VacEngine.Processor.Branch do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Assignment
  alias VacEngine.EctoHelpers

  schema "branches" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:deduction, Deduction)

    has_many(:conditions, Condition, on_replace: :delete)
    has_many(:assignments, Assignment, on_replace: :delete)

    field(:position, :integer)
    field(:description, :string)
  end

  def changeset(data, attrs, ctx) do
    attrs =
      attrs
      |> EctoHelpers.set_positions(:conditions)
      |> EctoHelpers.set_positions(:assignments)

    data
    |> cast(attrs, [:description, :position])
    |> change(blueprint_id: ctx.blueprint_id, workspace_id: ctx.workspace_id)
    |> cast_assoc(:conditions, with: {Condition, :changeset, [ctx]})
    |> cast_assoc(:assignments, with: {Assignment, :changeset, [ctx]})
    |> validate_required([])
  end
end
