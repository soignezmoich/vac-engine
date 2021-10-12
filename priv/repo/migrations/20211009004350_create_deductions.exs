defmodule VacEngine.Repo.Migrations.CreateDeductions do
  use Ecto.Migration

  def up do
    create table(:deductions) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:blueprint_id, references(:blueprints, on_delete: :delete_all),
        null: false
      )

      add(:position, :integer, null: false)
      add(:description, :string, size: 1000)
    end

    create(unique_index(:deductions, [:id, :blueprint_id]))
    create(unique_index(:deductions, [:id, :workspace_id]))
    create(unique_index(:deductions, [:position, :blueprint_id]))

    execute("
      ALTER TABLE deductions
        ADD CONSTRAINT deductions_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")
  end

  def down do
    drop(table(:deductions))
  end
end
