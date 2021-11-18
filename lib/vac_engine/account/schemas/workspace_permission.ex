defmodule VacEngine.Account.WorkspacePermission do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Account.Role

  schema "workspace_permissions" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:role, Role)

    field(:read, :boolean)
    field(:edit, :boolean)
    field(:publish, :boolean)
    field(:invite, :boolean)
  end

  @doc false
  def changeset(workspace_permission, attrs \\ %{}) do
    workspace_permission
    |> cast(attrs, [:read, :edit, :publish, :invite])
    |> validate_required([])
    |> link_flags()
  end

  defp link_flags(%Changeset{changes: %{read: false}} = changeset) do
    changeset
    |> change(%{edit: false, publish: false, invite: false})
  end

  defp link_flags(%Changeset{changes: %{edit: true}} = changeset) do
    changeset
    |> change(%{read: true})
  end

  defp link_flags(%Changeset{changes: %{publish: true}} = changeset) do
    changeset
    |> change(%{read: true})
  end

  defp link_flags(%Changeset{changes: %{invite: true}} = changeset) do
    changeset
    |> change(%{read: true})
  end

  defp link_flags(changeset), do: changeset
end
