defmodule VacEngine.Account.Workspace do
  @moduledoc """
  A workspace is the general container for blueprints and portals
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.WorkspacePermission
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Pub.Portal

  schema "workspaces" do
    timestamps(type: :utc_datetime)

    has_many(:permissions, WorkspacePermission)
    has_many(:blueprints, Blueprint)
    has_many(:portals, Portal)
    has_many(:publications, through: [:portals, :publications])

    field(:name, :string)
    field(:description, :string)
    field(:blueprint_count, :integer, virtual: true)
    field(:active_publication_count, :integer, virtual: true)
  end

  @doc false
  def changeset(workspace, attrs \\ %{}) do
    workspace
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, max: 100)
    |> validate_length(:description, max: 1000)
  end
end
