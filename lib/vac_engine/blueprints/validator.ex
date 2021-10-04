defmodule VacEngine.Blueprints.Validator do
  use Ecto.Schema
  import Ecto.Changeset
  alias VacEngine.Blueprints.ExpressionType

  @primary_key false
  embedded_schema do
    field(:description, :string)
    field(:expression, ExpressionType)
  end

  def changeset(data, attrs) do
    data
    |> cast(attrs, [:description, :expression])
    |> validate_required([:expression])
  end
end
