defmodule VacEngine.Processor.Branch do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Branch
  import VacEngine.EctoHelpers

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
      |> set_positions(:conditions)
      |> set_positions(:assignments)

    data
    |> cast(attrs, [:description, :position])
    |> change(blueprint_id: ctx.blueprint_id, workspace_id: ctx.workspace_id)
    |> cast_assoc(:conditions, with: {Condition, :changeset, [ctx]})
    |> cast_assoc(:assignments, with: {Assignment, :changeset, [ctx]})
    |> validate_required([])
  end

  def map_branch_element(changeset, attrs, type) do
    changeset
    |> prepare_changes(fn changeset ->
      branch = changeset.repo.get!(Branch, get_field(changeset, :branch_id))

      attrs
      |> get_in_attrs(:column)
      |> case do
        nil ->
          nil

        pos ->
          from(c in Column,
            where:
              c.deduction_id == ^branch.deduction_id and
                c.position == ^pos
          )
          |> changeset.repo.one()
      end
      |> case do
        nil ->
          changeset

        %Column{type: ^type} = column ->
          change(changeset, column_id: column.id)

        _column ->
          add_error(changeset, :column, "column must be #{type}")
      end
      |> change(deduction_id: branch.deduction_id)
    end)
  end
end
