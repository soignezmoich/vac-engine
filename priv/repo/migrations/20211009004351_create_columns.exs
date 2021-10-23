defmodule VacEngine.Repo.Migrations.CreateColumns do
  use Ecto.Migration

  def up do
    execute("CREATE TYPE column_type AS ENUM
      (
        'condition',
        'assignment'
      )")

    create table(:columns) do
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

      add(:type, :column_type, null: false, default: "condition")
      add(:position, :integer, null: false)
      add(:description, :string, size: 1000)
    end

    create(unique_index(:columns, [:id, :blueprint_id]))
    create(unique_index(:columns, [:id, :workspace_id]))
    create(unique_index(:columns, [:id, :deduction_id]))
    create(unique_index(:columns, [:position, :deduction_id]))

    execute("
      ALTER TABLE columns
        ADD CONSTRAINT columns_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE columns
        ADD CONSTRAINT columns_deduction_blueprint
        FOREIGN KEY (deduction_id, blueprint_id)
        REFERENCES deductions (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")
  end

  def down do
    drop(table(:columns))
    execute("DROP TYPE column_type")
  end
end
