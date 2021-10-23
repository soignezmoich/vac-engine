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
  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Meta
  import VacEngine.EctoHelpers
  import VacEngine.TupleHelpers
  import VacEngine.MapHelpers

  schema "assignments" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:deduction, Deduction)
    belongs_to(:branch, Branch)
    belongs_to(:column, Column)
    has_one(:expression, Expression)

    field(:description, :string)
    field(:target, :map, virtual: true)
  end

  def changeset(data, attrs, ctx) do
    attrs
    |> get_in_attrs(:target)
    |> Meta.cast_path()
    |> case do
      {:ok, path} ->
        attrs
        |> wrap_in_map(:expression, :ast)
        |> put_in_attrs(
          [:expression, :bindings],
          [
            %{position: -1, path: path}
          ]
        )
        |> ok()

      err ->
        err
    end
    |> case do
      {:ok, attrs} ->
        data
        |> cast(attrs, [:description])
        |> change(
          blueprint_id: ctx.blueprint_id,
          workspace_id: ctx.workspace_id
        )
        |> cast_assoc(:expression, with: {Expression, :changeset, [ctx]})
        |> validate_required([])
        |> Branch.map_branch_element(attrs, :assignment)

      {:error, msg} ->
        data
        |> cast(%{}, [:description])
        |> add_error(:target, msg)
    end
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

  def to_map(%Assignment{} = a) do
    %{
      expression: Expression.to_map(a.expression),
      target: a.target,
      description: a.description,
      column: get?(a.column, :position)
    }
    |> compact
  end
end
