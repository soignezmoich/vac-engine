defmodule VacEngine.Processor.Condition do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Expression
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Branch
  import VacEngine.EctoHelpers
  import VacEngine.EnumHelpers

  schema "conditions" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:deduction, Deduction)
    belongs_to(:branch, Branch)
    has_one(:expression, Expression)
    belongs_to(:column, Column)

    field(:description, :string)
  end

  @doc false
  def nested_changeset(data, attrs, ctx) do
    attrs = wrap_in_map(attrs, :expression, :ast)

    data
    |> cast(attrs, [:description])
    |> change(blueprint_id: ctx.blueprint_id, workspace_id: ctx.workspace_id)
    |> cast_assoc(:expression, with: {Expression, :nested_changeset, [ctx]})
    |> validate_required([])
    |> Branch.map_branch_element(attrs, :condition)
  end

  @doc false
  def insert_bindings(data, ctx) do
    data
    |> update_in([Access.key(:expression)], fn e ->
      Expression.insert_bindings(e, ctx)
    end)
  end

  @doc """
  Convert to map for serialization
  """
  def to_map(%Condition{} = c) do
    %{
      expression: Expression.to_map(c.expression),
      description: c.description,
      column: get?(c.column, :position)
    }
    |> compact
  end
end
