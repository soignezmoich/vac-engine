defmodule VacEngine.Processor.Condition do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Expression
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Branch
  alias VacEngine.EctoHelpers

  schema "conditions" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:deduction, Deduction)
    belongs_to(:branch, Branch)
    belongs_to(:expression, Expression)
    belongs_to(:column, Column)

    field(:description, :string)
  end

  def changeset(data, attrs, ctx) do
    attrs = EctoHelpers.wrap_in_map(attrs, :expression, :ast)

    data
    |> cast(attrs, [:description])
    |> change(blueprint_id: ctx.blueprint_id, workspace_id: ctx.workspace_id)
    |> cast_assoc(:expression, with: {Expression, :changeset, [ctx]})
    |> validate_required([])
    |> Branch.map_branch_element(attrs, :condition)
  end

  def insert_bindings(data, ctx) do
    data
    |> update_in([Access.key(:expression)], fn e ->
      Expression.insert_bindings(e, ctx)
    end)
  end
end
