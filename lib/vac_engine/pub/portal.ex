defmodule VacEngine.Pub.Portal do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Pub.Publication
  alias VacEngine.Processor.Blueprint

  schema "portals" do
    timestamps(type: :utc_datetime)

    field(:name, :string)
    field(:interface_hash, :string)
    field(:description, :string)

    has_many(:publications, Publication)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:workspace, Workspace)
  end

  @doc false
  def changeset(portal, attrs) do
    portal
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
