defmodule VacEngine.Processor.Blueprint.Function do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Processor.Blueprint.Branch

  @primary_key false
  embedded_schema do
    field(:description, :string)
    field(:editor_data, :map)
    embeds_many(:branches, Branch)
  end

  def changeset(data, attrs) do
    data
    |> cast(attrs, [:editor_data, :description])
    |> cast_embed(:branches, required: true)
    |> validate_required([])
  end

end
