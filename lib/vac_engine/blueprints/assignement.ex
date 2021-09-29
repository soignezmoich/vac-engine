defmodule VacEngine.Blueprints.Assignement do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Blueprints.ExpressionType
  alias VacEngine.Blueprints.NameType

  @primary_key false
  embedded_schema do
    field(:target, NameType)
    field(:description, :string)
    field(:expression, ExpressionType)
  end

  def changeset(data, attrs) do
    data
    |> cast(attrs, [:target, :description, :expression])
    |> validate_required([:target, :expression])
  end
end
