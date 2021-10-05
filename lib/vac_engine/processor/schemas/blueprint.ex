defmodule VacEngine.Processor.Blueprint do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Accounts.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.NameType

  schema "blueprints" do
    timestamps(type: :utc_datetime)

    field(:name, NameType)
    field(:description, :string)
    field(:editor_data, :map)
    embeds_many(:variables, Variable, on_replace: :delete)
    embeds_many(:deductions, Deduction, on_replace: :delete)

    belongs_to(:workspace, Workspace)
    belongs_to(:parent, Blueprint)
    field(:draft, :boolean)
  end

  def changeset(data, attrs) do
    attrs = VacEngine.Utils.accept_array_or_map_for_embed(attrs, :variables)

    data
    |> cast(attrs, [:name, :editor_data, :description])
    |> cast_embed(:variables)
    |> cast_embed(:deductions)
    |> validate_required([:name])
  end
end
