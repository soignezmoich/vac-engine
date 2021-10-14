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
    field(:mapping, Ecto.Enum, values: Meta.mappings())
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
      :mapping,
      :description
    ])
    |> change(blueprint_id: ctx.blueprint_id, workspace_id: ctx.workspace_id)
    |> cast_assoc(:children, with: {Variable, :changeset, [ctx]})
    |> cast_assoc(:default,
      with: {Expression, :changeset, [ctx, nobindings: true]}
    )
    |> validate_required([:name, :type])
    |> validate_container()
    |> validate_children_state()
  end

  def input?(var) do
    Meta.input?(var.mapping)
  end

  def output?(var) do
    Meta.output?(var.mapping)
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
    mapping = get_field(changeset, :mapping)

    get_field(changeset, :children)
    |> Enum.any?(fn child ->
      (input?(child) && !Meta.input?(mapping)) ||
        (output?(child) && !Meta.output?(mapping))
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
