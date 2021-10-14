defmodule VacEngine.Repo.Migrations.CreateConditions do
  use Ecto.Migration

  def up do
    create table(:conditions) do
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

      add(:branch_id, references(:branches, on_delete: :delete_all), null: false)

      add(:expression_id, references(:expressions, on_delete: :delete_all),
        null: false
      )

      add(:column_id, references(:columns, on_delete: :delete_all))

      add(:description, :string, size: 1000)
    end

    create(index(:conditions, [:branch_id]))
    create(index(:conditions, [:column_id]))
    create(unique_index(:conditions, [:id, :blueprint_id]))
    create(unique_index(:conditions, [:id, :workspace_id]))
    create(unique_index(:conditions, [:id, :deduction_id]))
    create(unique_index(:conditions, [:id, :branch_id]))
    create(unique_index(:conditions, [:id, :expression_id]))
    create(unique_index(:conditions, [:id, :column_id]))

    execute("
      ALTER TABLE conditions
        ADD CONSTRAINT conditions_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE conditions
        ADD CONSTRAINT conditions_deduction_blueprint
        FOREIGN KEY (deduction_id, blueprint_id)
        REFERENCES deductions (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE conditions
        ADD CONSTRAINT conditions_branch_blueprint
        FOREIGN KEY (branch_id, blueprint_id)
        REFERENCES branches (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE conditions
        ADD CONSTRAINT conditions_expression_blueprint
        FOREIGN KEY (expression_id, blueprint_id)
        REFERENCES expressions (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE conditions
        ADD CONSTRAINT conditions_column_blueprint
        FOREIGN KEY (column_id, blueprint_id)
        REFERENCES columns (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")
  end

  def down do
    drop(table(:conditions))
  end
end
