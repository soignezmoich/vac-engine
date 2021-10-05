defmodule VacEngine.Processor.Assignement do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Processor.ExpressionType
  alias VacEngine.Processor.NamePathType

  @primary_key false
  embedded_schema do
    field(:target, NamePathType)
    field(:description, :string)
    field(:expression, ExpressionType)
  end

  def changeset(data, attrs) do
    data
    |> cast(attrs, [:target, :description, :expression])
    |> validate_required([:target, :expression])
  end
end
