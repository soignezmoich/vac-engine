defmodule VacEngine.Pub.Publication do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Pub.Portal
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Pub.Publication

  schema "publications" do
    timestamps(type: :utc_datetime)

    field(:activated_at, :utc_datetime)
    field(:deactivated_at, :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:portal, Portal)
    belongs_to(:blueprint, Blueprint)
  end

  @doc false
  def changeset(publication, attrs) do
    publication
    |> cast(attrs, [:activated_at, :deactivated_at])
    |> validate_required([])
  end

  def active?(%Publication{deactivated_at: nil}), do: true
  def active?(_), do: false
end
