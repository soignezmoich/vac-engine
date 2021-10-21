defmodule VacEngine.Repo.Migrations.CreateBlueprintPermissions do
  use Ecto.Migration

  def change do
    create table(:blueprint_permissions) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:blueprint_id, references(:blueprints, on_delete: :delete_all),
        null: false
      )

      add(:role_id, references(:roles, on_delete: :delete_all), null: false)

      add(:read, :boolean, null: false, default: false)
      add(:edit, :boolean, null: false, default: false)
      add(:test, :boolean, null: false, default: false)
    end

    create(index(:blueprint_permissions, [:blueprint_id]))
    create(index(:blueprint_permissions, [:role_id]))

    create(
      index(:blueprint_permissions, [:blueprint_id, :role_id], unique: true)
    )

    execute("
      ALTER TABLE blueprint_permissions
        ADD CONSTRAINT blueprint_permissions_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")
  end
end
