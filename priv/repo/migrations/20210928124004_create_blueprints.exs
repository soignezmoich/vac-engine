defmodule VacEngine.Repo.Migrations.CreateBlueprints do
  use Ecto.Migration

  def change do
    create table(:blueprints) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :restrict),
        null: false
      )

      add(:parent_id, references(:blueprints, on_delete: :restrict))
      add(:name, :string, size: 100, null: false)
      add(:description, :string, size: 1000)
      add(:editor_data, :jsonb)
      add(:variables, :jsonb)
      add(:deductions, :jsonb)
      add(:draft, :boolean, null: false, default: false)
      add(:interface_hash, :string, size: 300)
    end

    create(index(:blueprints, [:workspace_id]))
    create(index(:blueprints, [:parent_id]))

    create(unique_index(:blueprints, [:id, :workspace_id]))
  end
end
