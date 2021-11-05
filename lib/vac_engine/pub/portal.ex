defmodule VacEngine.Pub.Portal do
  @moduledoc """
  A portal is an API entry point with multiple publications
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Pub.Publication
  alias VacEngine.Pub.Portal

  schema "portals" do
    timestamps(type: :utc_datetime)

    field(:name, :string)
    field(:interface_hash, :string)
    field(:description, :string)

    has_many(:publications, Publication)
    has_one(:active_publication, Publication)
    belongs_to(:workspace, Workspace)
  end

  @doc false
  def changeset(portal, attrs) do
    portal
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end

  @doc """
  Return the active publication or nil if not active
  """
  def active_publication(%Portal{publications: pubs}) do
    Enum.find(pubs, &Publication.active?/1)
  end

  def active_publication(_), do: nil

  @doc """
  Is the publication actually active?
  """
  def active?(portal) do
    not is_nil(active_publication(portal))
  end
end
