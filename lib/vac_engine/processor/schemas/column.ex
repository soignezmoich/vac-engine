defmodule VacEngine.Processor.Column do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Meta
  import VacEngine.EctoHelpers

  schema "columns" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:deduction, Deduction)
    belongs_to(:variable, Variable)

    has_many(:conditions, Condition)
    has_many(:assignments, Assignment)

    field(:type, Ecto.Enum, values: ~w(condition assignment)a)
    field(:position, :integer)
    field(:description, :string)
  end

  def changeset(data, attrs, ctx) do
    variable_id =
      attrs
      |> get_in_attrs(:variable)
      |> Meta.cast_path()
      |> case do
        {:ok, path} ->
          Map.get(ctx.variable_path_index, path)
          |> case do
            nil -> nil
            var -> var.id
          end

        _ ->
          nil
      end

    data
    |> cast(attrs, [:description, :position, :type])
    |> change(
      variable_id: variable_id,
      blueprint_id: ctx.blueprint_id,
      workspace_id: ctx.workspace_id
    )
    |> validate_required([])
  end
end
