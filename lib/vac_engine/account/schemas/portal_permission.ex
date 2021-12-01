defmodule VacEngine.Account.PortalPermission do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Pub.Portal
  alias VacEngine.Account.Role

  schema "portal_permissions" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:portal, Portal)
    belongs_to(:role, Role)

    field(:read, :boolean)
    field(:run, :boolean)
    field(:write, :boolean)
  end

  @doc false
  def changeset(workspace_permission, attrs \\ %{}) do
    workspace_permission
    |> cast(attrs, [:read, :run, :write])
    |> validate_required([])
    |> link_flags()
  end

  defp link_flags(%Changeset{changes: %{read: false}} = changeset) do
    changeset
    |> change(%{write: false, run: false})
  end

  defp link_flags(%Changeset{changes: %{write: true}} = changeset) do
    changeset
    |> change(%{read: true})
  end

  defp link_flags(%Changeset{changes: %{run: true}} = changeset) do
    changeset
    |> change(%{read: true})
  end

  defp link_flags(changeset), do: changeset
end
