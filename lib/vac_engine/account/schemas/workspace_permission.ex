defmodule VacEngine.Account.WorkspacePermission do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Account.Role

  @flags [
    :write_blueprints,
    :read_blueprints,
    :write_portals,
    :run_portals,
    :read_portals
  ]

  schema "workspace_permissions" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:role, Role)

    field(:read_blueprints, :boolean)
    field(:write_blueprints, :boolean)
    field(:run_portals, :boolean)
    field(:read_portals, :boolean)
    field(:write_portals, :boolean)
  end

  @doc false
  def changeset(workspace_permission, attrs \\ %{}) do
    workspace_permission
    |> cast(attrs, @flags)
    |> validate_required([])
    |> link_flags(@flags, %{})
  end

  defp link_flags(
         %Changeset{changes: %{write_blueprints: true}} = changeset,
         [:write_blueprints | flags],
         changes
       ) do
    changes =
      Map.merge(changes, %{
        read_blueprints: true
      })

    link_flags(changeset, flags, changes)
  end

  defp link_flags(
         %Changeset{changes: %{write_blueprints: false}} = changeset,
         [:write_blueprints | flags],
         changes
       ) do
    changes =
      Map.merge(changes, %{
        write_portals: false
      })

    link_flags(changeset, flags, changes)
  end

  defp link_flags(
         %Changeset{changes: %{read_blueprints: false}} = changeset,
         [:read_blueprints | flags],
         changes
       ) do
    changes =
      Map.merge(changes, %{
        read_portals: false,
        write_portals: false,
        write_blueprints: false
      })

    link_flags(changeset, flags, changes)
  end

  defp link_flags(
         %Changeset{changes: %{write_portals: true}} = changeset,
         [:write_portals | flags],
         changes
       ) do
    changes =
      Map.merge(changes, %{
        read_portals: true,
        read_blueprints: true,
        write_blueprints: true
      })

    link_flags(changeset, flags, changes)
  end

  defp link_flags(
         %Changeset{changes: %{read_portals: true}} = changeset,
         [:read_portals | flags],
         changes
       ) do
    changes =
      Map.merge(changes, %{
        read_blueprints: true
      })

    link_flags(changeset, flags, changes)
  end

  defp link_flags(
         %Changeset{changes: %{run_portals: true}} = changeset,
         [:run_portals | flags],
         changes
       ) do
    changes =
      Map.merge(changes, %{
        read_portals: true
      })

    link_flags(changeset, flags, changes)
  end

  defp link_flags(
         %Changeset{changes: %{read_portals: false}} = changeset,
         [:read_portals | flags],
         changes
       ) do
    changes =
      Map.merge(changes, %{
        write_portals: false,
        run_portals: false
      })

    link_flags(changeset, flags, changes)
  end

  defp link_flags(changeset, [_ | tail], changes) do
    changeset
    |> link_flags(tail, changes)
  end

  defp link_flags(changeset, [], changes) do
    changeset
    |> change(changes)
  end
end
