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

      add(:ast, :map)
    end

    create(unique_index(:expressions, [:id, :blueprint_id]))

    execute("
      ALTER TABLE expressions
        ADD CONSTRAINT expressions_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

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
