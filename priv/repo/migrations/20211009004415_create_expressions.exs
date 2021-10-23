defmodule VacEngine.Repo.Migrations.CreateExpressions do
  use Ecto.Migration

  def up do
    create table(:expressions) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:blueprint_id, references(:blueprints, on_delete: :delete_all),
        null: false
      )

      add(:variable_id, references(:variables, on_delete: :delete_all))
      add(:column_id, references(:columns, on_delete: :delete_all))
      add(:condition_id, references(:conditions, on_delete: :delete_all))
      add(:assignment_id, references(:assignments, on_delete: :delete_all))

      add(:ast, :map)
    end

    create(unique_index(:expressions, [:id, :blueprint_id]))
    create(unique_index(:expressions, [:id, :variable_id]))
    create(unique_index(:expressions, [:id, :column_id]))
    create(unique_index(:expressions, [:id, :condition_id]))
    create(unique_index(:expressions, [:id, :assignment_id]))

    execute("
      ALTER TABLE expressions
        ADD CONSTRAINT expressions_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE expressions
        ADD CONSTRAINT expressions_variable_blueprint
        FOREIGN KEY (variable_id, blueprint_id)
        REFERENCES variables (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE expressions
        ADD CONSTRAINT expressions_column_blueprint
        FOREIGN KEY (column_id, blueprint_id)
        REFERENCES columns (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE expressions
        ADD CONSTRAINT expressions_condition_blueprint
        FOREIGN KEY (condition_id, blueprint_id)
        REFERENCES conditions (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE expressions
        ADD CONSTRAINT expressions_assignment_blueprint
        FOREIGN KEY (assignment_id, blueprint_id)
        REFERENCES assignments (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    create(
      constraint(
        :expressions,
        "expressions_not_orpha",
        check: """
        variable_id IS NOT NULL OR
        column_id IS NOT NULL OR
        condition_id IS NOT NULL OR
        assignment_id IS NOT NULL
        """
      )
    )

    create(
      constraint(
        :expressions,
        "expressions_max_ast_size",
        check: "pg_column_size(ast) < 10000"
      )
    )
  end

  def down do
    drop(table(:expressions))
  end
end
