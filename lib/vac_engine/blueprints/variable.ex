defmodule VacEngine.Blueprints.Variable do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Blueprints.NameType
  alias VacEngine.Blueprints.ExpressionType
  alias VacEngine.Processor.Compiler
  alias VacEngine.Processor.Meta
  alias VacEngine.Blueprints.Variable
  alias VacEngine.Blueprints.Validator
  alias VacEngine.Utils

  @primary_key false
  embedded_schema do
    field(:type, Ecto.Enum, values: Meta.types())
    field(:input, :boolean, default: false)
    field(:output, :boolean, default: false)
    field(:name, NameType)
    field(:description, :string)
    field(:editor_data, :map)
    field(:default, ExpressionType)
    embeds_many(:validators, Validator, on_replace: :delete)
    embeds_many(:children, Variable, on_replace: :delete)
  end

  def changeset(data, attrs) do
    attrs =
      attrs
      |> Utils.accept_array_or_map_for_embed(:children)
      |> Utils.accept_array_or_map_for_embed(:validators)

    data
    |> cast(attrs, [
      :default,
      :name,
      :type,
      :input,
      :output,
      :description,
      :editor_data
    ])
    |> cast_embed(:validators)
    |> cast_embed(:children)
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
