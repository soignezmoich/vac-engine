defmodule VacEngine.Processor.Column do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Expression
  alias VacEngine.Processor.Binding
  import VacEngine.EctoHelpers
  import VacEngine.PipeHelpers
  import VacEngine.EnumHelpers
  alias VacEngine.Processor.Meta

  schema "columns" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:deduction, Deduction)
    has_one(:expression, Expression)

    has_many(:conditions, Condition)
    has_many(:assignments, Assignment)

    field(:type, Ecto.Enum, values: ~w(condition assignment)a)
    field(:position, :integer)
    field(:description, :string)
    field(:variable, :map, virtual: true)
  end

  @doc false
  def changeset(data, attrs) do
    data
    |> cast(attrs, [:description, :position])
    |> validate_required([])
    |> prepare_changes(fn changeset ->
      deduction_id = get_field(changeset, :deduction_id)

      changeset
      |> constraint_position()
      |> shift_position(:deduction_id, deduction_id)
    end)
  end

  @doc false
  def nested_changeset(data, attrs, ctx) do
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
        |> cast_assoc(:expression, with: {Expression, :nested_changeset, [ctx]})
        |> validate_required([])
        |> prepare_changes(fn changeset ->
          deduction_id = get_field(changeset, :deduction_id)

          changeset
          |> constraint_position()
          |> shift_position(:deduction_id, deduction_id)
        end)

      {:error, msg} ->
        data
        |> cast(%{}, [:description])
        |> add_error(:variable, msg)
    end
  end

  @doc false
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

  @doc """
  Convert to map for serialization
  """
  def to_map(%Column{} = c) do
    %{
      variable: c.variable,
      description: c.description,
      type: c.type
    }
    |> compact
  end

  def constraint_position(changeset) do
    deduction_id = get_field(changeset, :deduction_id)
    position = get_field(changeset, :position)
    type = get_field(changeset, :type)

    offset =
      case changeset.action do
        :update -> -1
        :insert -> 0
      end

    from(c in Column,
      where: c.deduction_id == ^deduction_id and c.type == :assignment,
      order_by: c.position,
      select: c.position,
      limit: 1
    )
    |> changeset.repo.one()
    |> case do
      nil ->
        changeset

      split_position ->
        position =
          case type do
            :condition ->
              min(position, split_position + offset)

            :assignment ->
              max(position, split_position)

            _ ->
              raise "invalid type"
          end

        put_change(changeset, :position, position)
    end
  end
end
