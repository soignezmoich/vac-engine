defmodule VacEngine.Repo.Migrations.CreatePortals do
  use Ecto.Migration

  def change do
    create table(:portals) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :restrict),
        null: false
      )

      add(:interface_hash, :string, size: 300)
      add(:name, :string, size: 100, null: false)
      add(:description, :string, size: 1000)
    end

    create(index(:portals, [:workspace_id]))
    create(unique_index(:portals, [:id, :workspace_id]))
  end
end
