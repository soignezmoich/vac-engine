defmodule VacEngine.Repo.Migrations.CreateVariables do
  use Ecto.Migration

  def up do
    execute("CREATE TYPE variable_type AS ENUM
      (
        'boolean',
        'integer',
        'number',
        'string',
        'date',
        'datetime',
        'map',
        'boolean[]',
        'integer[]',
        'number[]',
        'string[]',
        'date[]',
        'datetime[]',
        'map[]'
      )")

    execute("CREATE TYPE variable_mapping AS ENUM
      (
        'none',
        'in_required',
        'in_optional',
        'inout_required',
        'inout_optional',
        'out'
      )")

    create table(:variables) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:blueprint_id, references(:blueprints, on_delete: :delete_all),
        null: false
      )

      add(:parent_id, references(:variables, on_delete: :delete_all))

      add(:default_id, references(:expressions, on_delete: :delete_all))

      add(:type, :variable_type, null: false)
      add(:name, :string, size: 100, null: false)
      add(:description, :string, size: 1000)
      add(:mapping, :variable_mapping, null: false, default: "none")
      add(:enum, :jsonb)
    end

    create(index(:variables, [:workspace_id]))
    create(index(:variables, [:blueprint_id]))
    create(unique_index(:variables, [:id, :blueprint_id]))
    create(unique_index(:variables, [:id, :workspace_id]))
    create(unique_index(:variables, [:blueprint_id, :parent_id, :name]))

    create(
      constraint(
        :variables,
        "variables_name_slug",
        check: "name ~ '^[a-z][a-z0-9_]+$'"
      )
    )

    execute("
      ALTER TABLE variables
        ADD CONSTRAINT variables_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE variables
        ADD CONSTRAINT variables_parent_blueprint
        FOREIGN KEY (parent_id, blueprint_id)
        REFERENCES variables (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    execute("
      ALTER TABLE variables
        ADD CONSTRAINT variables_default_blueprint
        FOREIGN KEY (default_id, blueprint_id)
        REFERENCES expressions (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")
  end

  def down do
    drop(table(:variables))
    execute("DROP TYPE variable_type")
    execute("DROP TYPE variable_mapping")
  end
end
