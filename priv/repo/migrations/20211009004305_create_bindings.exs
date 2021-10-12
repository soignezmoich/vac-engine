defmodule VacEngine.Repo.Migrations.CreateBindings do
  use Ecto.Migration

  def up do
    create table(:bindings) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:blueprint_id, references(:blueprints, on_delete: :delete_all),
        null: false
      )

      add(:expression_id, references(:expressions, on_delete: :delete_all),
        null: false
      )

      add(:position, :integer, null: false)
    end

    create(unique_index(:bindings, [:id, :workspace_id]))
    create(unique_index(:bindings, [:id, :blueprint_id]))
    create(unique_index(:bindings, [:position, :expression_id]))

    execute("
      ALTER TABLE bindings
        ADD CONSTRAINT bindings_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE bindings
        ADD CONSTRAINT bindings_expression_blueprint
        FOREIGN KEY (expression_id, blueprint_id)
        REFERENCES expressions (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")
  end

  def down do
    drop(table(:bindings))
  end
end
