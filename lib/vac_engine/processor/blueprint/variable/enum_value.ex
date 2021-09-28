defmodule VacEngine.Processor.Blueprint.Variable.EnumValue do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:value, :string)
    field(:description, :string)
  end

  def changeset(data, attrs) do
    data
    |> cast(attrs, [:value, :description])
  end
end
