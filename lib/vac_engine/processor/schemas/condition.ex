defmodule VacEngine.Processor.Condition do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Processor.ExpressionType
  alias VacEngine.Processor.NameType

  @primary_key false
  embedded_schema do
    field(:name, NameType)
    field(:description, :string)
    field(:expression, ExpressionType)
  end

  def changeset(data, attrs) do
    data
    |> cast(attrs, [:name, :description, :expression])
    |> validate_required([:expression])
  end
end