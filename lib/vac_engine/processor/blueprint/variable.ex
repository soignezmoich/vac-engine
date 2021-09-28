defmodule VacEngine.Processor.Blueprint.Variable do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Processor.Blueprint.Variable.EnumValue
  alias VacEngine.Processor.Blueprint.NameType
  alias VacEngine.Processor.Blueprint.ExpressionType

  @types ~w(
    boolean
    integer
    number
    string
    enum
    date
    datetime
  )a

  @primary_key false
  embedded_schema do
    field(:type, Ecto.Enum, values: @types)
    field(:input, :boolean)
    field(:output, :boolean)
    field(:name, NameType)
    field(:description, :string)
    field(:editor_data, :map)
    field(:default, ExpressionType)
    embeds_many(:values, EnumValue)
  end

  def changeset(data, attrs) do
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
    |> map_values()
    |> cast_embed(:values)
    |> validate_required([:default, :name, :type, :input, :output])
  end

  defp map_values(%{params: %{"values" => vals} = params} = changeset) do
    vals =
      Enum.map(vals, fn v ->
        cond do
          is_map(v) -> v
          v -> %{value: to_string(v)}
        end
      end)

    params = Map.put(params, "values", vals)
    Map.put(changeset, :params, params)
  end

  defp map_values(changeset), do: changeset
end
