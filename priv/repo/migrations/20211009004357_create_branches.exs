defmodule VacEngine.Repo.Migrations.CreateBranches do
  use Ecto.Migration

  def up do
    create table(:branches) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:blueprint_id, references(:blueprints, on_delete: :delete_all),
        null: false
      )

      add(:deduction_id, references(:deductions, on_delete: :delete_all),
        null: false
      )

      add(:position, :integer, null: false)
      add(:description, :string, size: 1000)
    end

    create(index(:branches, [:deduction_id]))
    create(unique_index(:branches, [:id, :blueprint_id]))
    create(unique_index(:branches, [:id, :workspace_id]))
    create(unique_index(:branches, [:id, :deduction_id]))
    create(unique_index(:branches, [:position, :deduction_id]))

    execute("
      ALTER TABLE branches
        ADD CONSTRAINT branches_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE branches
        ADD CONSTRAINT branches_deduction_blueprint
        FOREIGN KEY (deduction_id, blueprint_id)
        REFERENCES deductions (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")
  end

  def down do
    drop(table(:branches))
  end
end
