defmodule VacEngine.Account.BlueprintPermission do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Account.Role

  schema "blueprint_permissions" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:role, Role)

    field(:read, :boolean)
    field(:edit, :boolean)
    field(:test, :boolean)
  end

  @doc false
  def changeset(workspace_permission, attrs \\ %{}) do
    workspace_permission
    |> cast(attrs, [])
    |> validate_required([])
    |> link_flags()
  end

  defp link_flags(%Changeset{changes: %{read: false}} = changeset) do
    changeset
    |> change(%{edit: false, test: false})
  end

  defp link_flags(%Changeset{changes: %{edit: true}} = changeset) do
    changeset
    |> change(%{read: true})
  end

  defp link_flags(%Changeset{changes: %{test: true}} = changeset) do
    changeset
    |> change(%{read: true})
  end

  defp link_flags(changeset), do: changeset
end
