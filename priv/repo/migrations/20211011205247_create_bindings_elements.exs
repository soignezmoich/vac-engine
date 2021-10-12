defmodule VacEngine.Repo.Migrations.CreateBindingsElements do
  use Ecto.Migration

  def up do
    create table(:bindings_elements) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:blueprint_id, references(:blueprints, on_delete: :delete_all),
        null: false
      )

      add(:binding_id, references(:bindings, on_delete: :delete_all),
        null: false
      )

      add(:variable_id, references(:variables, on_delete: :delete_all),
        null: false
      )

      add(:position, :integer, null: false)
      add(:index, :integer)
    end

    create(unique_index(:bindings_elements, [:id, :workspace_id]))
    create(unique_index(:bindings_elements, [:id, :blueprint_id]))
    create(unique_index(:bindings_elements, [:variable_id, :binding_id]))
    create(unique_index(:bindings_elements, [:position, :binding_id]))

    execute("
      ALTER TABLE bindings_elements
        ADD CONSTRAINT bindings_elements_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE bindings_elements
        ADD CONSTRAINT bindings_elements_variable_blueprint
        FOREIGN KEY (variable_id, blueprint_id)
        REFERENCES variables (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE bindings_elements
        ADD CONSTRAINT bindings_elements_binding_blueprint
        FOREIGN KEY (binding_id, blueprint_id)
        REFERENCES bindings (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")
  end

  def down do
    drop(table(:bindings_elements))
  end
end
