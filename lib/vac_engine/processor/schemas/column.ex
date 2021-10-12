defmodule VacEngine.Processor.Column do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Assignment

  schema "columns" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:deduction, Deduction)

    has_many(:conditions, Condition)
    has_many(:assignments, Assignment)

    field(:position, :integer)
    field(:description, :string)
  end

  def changeset(data, attrs, ctx) do
    data
    |> cast(attrs, [:description])
    |> validate_required([])
  end
end
