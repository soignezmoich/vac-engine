defmodule VacEngine.Processor.Blueprint.Branch do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Processor.Blueprint.Condition
  alias VacEngine.Processor.Blueprint.Assignement

  @primary_key false
  embedded_schema do
    field(:description, :string)
    field(:editor_data, :map)
    embeds_many(:conditions, Condition)
    embeds_many(:assignements, Assignement)
  end

  def changeset(data, attrs) do
    data
    |> cast(attrs, [:description, :editor_data])
    |> cast_embed(:conditions, required: true)
    |> cast_embed(:assignements, required: true)
    |> validate_required([])
  end

end
