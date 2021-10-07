defmodule VacEngine.Processor.Branch do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Assignement

  @primary_key false
  embedded_schema do
    field(:description, :string)
    field(:editor_data, :map)
    embeds_many(:conditions, Condition, on_replace: :delete)
    embeds_many(:assignements, Assignement, on_replace: :delete)
  end

  def changeset(data, attrs) do
    data
    |> cast(attrs, [:description, :editor_data])
    |> cast_embed(:conditions)
    |> cast_embed(:assignements)
    |> validate_required([])
  end
end
