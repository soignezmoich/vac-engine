defmodule VacEngine.Processor.Column do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Expression
  alias VacEngine.Processor.Binding
  import VacEngine.EctoHelpers
  import VacEngine.TupleHelpers
  alias VacEngine.Processor.Meta

  schema "columns" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:deduction, Deduction)
    belongs_to(:expression, Expression)

    has_many(:conditions, Condition)
    has_many(:assignments, Assignment)

    field(:type, Ecto.Enum, values: ~w(condition assignment)a)
    field(:position, :integer)
    field(:description, :string)
  end

  def changeset(data, attrs, ctx) do
    attrs
    |> get_in_attrs(:variable)
    |> Meta.cast_path()
    |> case do
      {:ok, path} ->
        attrs
        |> put_in_attrs(:expression, %{})
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
        |> cast(attrs, [:description, :position, :type])
        |> change(
          blueprint_id: ctx.blueprint_id,
          workspace_id: ctx.workspace_id
        )
        |> cast_assoc(:expression, with: {Expression, :changeset, [ctx]})
        |> validate_required([])

      {:error, msg} ->
        data
        |> cast(%{}, [:description])
        |> add_error(:variable, msg)
    end
  end

  def insert_bindings(data, ctx) do
    varpath =
      data
      |> get_in([
        Access.key(:expression),
        Access.key(:bindings),
        Access.filter(fn b -> b.position == -1 end)
      ])
      |> List.first()
      |> Binding.to_path(ctx)

    data
    |> put_in([Access.key(:variable)], varpath)
    |> update_in([Access.key(:expression)], fn e ->
      Expression.insert_bindings(e, ctx)
    end)
  end
end
