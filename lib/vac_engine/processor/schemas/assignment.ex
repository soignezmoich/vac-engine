defmodule VacEngine.Processor.Assignment do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Binding
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Expression
  alias VacEngine.Processor.Branch
  import VacEngine.EctoHelpers

  schema "assignments" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:deduction, Deduction)
    belongs_to(:branch, Branch)
    belongs_to(:column, Column)
    belongs_to(:expression, Expression)

    field(:description, :string)
    field(:target, :map, virtual: true)
  end

  def changeset(data, attrs, ctx) do
    attrs =
      attrs
      |> wrap_in_map(:expression, :ast)
      |> put_in_attrs(
        [:expression, :bindings],
        [
          %{position: -1, path: get_in_attrs(attrs, :target)}
        ]
      )

    data
    |> cast(attrs, [:description])
    |> change(blueprint_id: ctx.blueprint_id, workspace_id: ctx.workspace_id)
    |> cast_assoc(:expression, with: {Expression, :changeset, [ctx]})
    |> validate_required([])
    |> Branch.map_branch_element(attrs, :assignment)
  end

  def insert_bindings(data, ctx) do
    target =
      data
      |> get_in([
        Access.key(:expression),
        Access.key(:bindings),
        Access.filter(fn b -> b.position == -1 end)
      ])
      |> List.first()
      |> Binding.to_path(ctx)

    data
    |> put_in([Access.key(:target)], target)
    |> update_in([Access.key(:expression)], fn e ->
      Expression.insert_bindings(e, ctx)
    end)
  end
end
