defmodule VacEngine.Processor.Variable do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Expression
  alias VacEngine.Processor.Meta
  alias VacEngine.Processor.Variable
  alias VacEngine.EctoHelpers

  schema "variables" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)

    has_many(:children, Variable, on_replace: :delete, foreign_key: :parent_id)
    belongs_to(:parent, Variable)

    belongs_to(:default, Expression)

    field(:type, Ecto.Enum, values: Meta.types())
    field(:input, :boolean, default: false)
    field(:output, :boolean, default: false)
    field(:name, :string)
    field(:description, :string)

    field(:path, {:array, :string}, virtual: true)
  end

  def changeset(data, attrs, ctx) do
    attrs =
      attrs
      |> EctoHelpers.accept_array_or_map_for_embed(:children)
      |> EctoHelpers.wrap_in_map(:default, :ast)

    data
    |> cast(attrs, [
      :name,
      :type,
      :input,
      :output,
      :description
    ])
    |> change(blueprint_id: ctx.blueprint_id, workspace_id: ctx.workspace_id)
    |> cast_assoc(:children, with: {Variable, :changeset, [ctx]})
    |> cast_assoc(:default,
      with: {Expression, :changeset, [ctx, nobindings: true]}
    )
    |> validate_required([:name, :type, :input, :output])
    |> validate_container()
    |> validate_children_state()
  end

  defp validate_container(changeset) do
    if length(get_field(changeset, :children)) > 0 &&
         !Meta.has_nested_type?(get_field(changeset, :type)) do
      add_error(changeset, :children, "only map and map[] can have children")
    else
      changeset
    end
  end

  defp validate_children_state(changeset) do
    input = get_field(changeset, :input)
    output = get_field(changeset, :output)

    get_field(changeset, :children)
    |> Enum.any?(fn child ->
      (!input && child.input) ||
        (!output && child.output)
    end)
    |> if do
      add_error(
        changeset,
        :children,
        "children cannot be in input or output if parent is not"
      )
    else
      changeset
    end
  end
end
