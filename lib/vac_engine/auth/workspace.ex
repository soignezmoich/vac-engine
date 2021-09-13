defmodule VacEngine.Auth.Workspace do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workspaces" do
    timestamps(type: :utc_datetime)

    field(:name, :string)
    field(:description, :string)
  end

  @doc false
  def changeset(workspace, attrs) do
    workspace
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
