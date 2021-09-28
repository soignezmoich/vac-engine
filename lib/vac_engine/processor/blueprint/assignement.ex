defmodule VacEngine.Processor.Blueprint.Assignement do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Processor.Blueprint.ExpressionType
  alias VacEngine.Processor.Blueprint.NameType

  @primary_key false
  embedded_schema do
    field(:variable, NameType)
    field(:description, :string)
    field(:expression, ExpressionType)
  end

  def changeset(data, attrs) do
    data
    |> cast(attrs, [:variable, :description, :expression])
    |> validate_required([:variable, :expression])
  end

end
