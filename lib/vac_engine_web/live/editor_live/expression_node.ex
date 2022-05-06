defmodule VacEngineWeb.EditorLive.ExpressionNode do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias VacEngine.Processor.Meta
  alias VacEngine.Processor.Convert

  embedded_schema do
    field(:composed_type, :string)
    field(:type, Ecto.Enum, values: ~w(variable function constant)a)
    field(:return_type, Ecto.Enum, values: Meta.types())
    field(:constant, :string)
    field(:constant_string, :string)
    field(:variable, :string)
    field(:function, :string)
    field(:set_nil, :boolean)
    field(:delete, :boolean)
  end

  @doc false
  def changeset(data, attrs \\ %{}) do
    data
    |> cast(attrs, [:composed_type, :constant, :variable, :function])
    |> update_type()
    |> update_constant()
    |> Map.put(:action, :insert)
  end

  def update_type(changeset) do
    get_field(changeset, :composed_type)
    |> String.split(".")
    |> case do
      [return_type, node_type] ->
        return_type = String.to_existing_atom(return_type)
        node_type = String.to_existing_atom(node_type)

        change(changeset,
          return_type: return_type,
          type: node_type,
          set_nil: false,
          delete: false
        )

      ["set_nil"] ->
        change(changeset,
          set_nil: true,
          delete: false,
          return_type: nil,
          type: nil
        )

      ["delete"] ->
        change(changeset,
          set_nil: false,
          delete: true,
          return_type: nil,
          type: nil
        )
    end
  end

  def update_constant(changeset) do
    if get_field(changeset, :type) == :constant do
      type = get_field(changeset, :return_type)
      value = get_field(changeset, :constant)

      try do
        value = Convert.parse_string(value, type)
        change(changeset, constant: value, constant_string: to_string(value))
      catch
        _ ->
          add_error(changeset, :constant, format_error(value, type))
      end
    else
      changeset
    end
  end

  defp format_error(_value, :date) do
    "format is YYYY-MM-DD"
  end

  defp format_error(_value, :datetime) do
    "format is YYYY-MM-DD hh:mm:ss"
  end

  defp format_error(_value, :boolean) do
    "format is true or false"
  end

  defp format_error(value, :integer) do
    "invalid integer #{value}"
  end

  defp format_error(value, :number) do
    "invalid number #{value}"
  end

  defp format_error(value, _) do
    "invalid value #{value}"
  end
end
