defmodule VacEngine.Account.Workspace do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.WorkspacePermission
  alias VacEngine.Processor.Blueprint

  schema "workspaces" do
    timestamps(type: :utc_datetime)

    has_many(:permissions, WorkspacePermission)
    has_many(:blueprints, Blueprint)

    field(:name, :string)
    field(:description, :string)
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
