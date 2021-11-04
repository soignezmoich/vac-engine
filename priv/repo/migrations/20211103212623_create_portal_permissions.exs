defmodule VacEngine.Repo.Migrations.CreatePortalPermissions do
  use Ecto.Migration

  def up do
    create table(:portal_permissions) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:portal_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:role_id, references(:roles, on_delete: :delete_all), null: false)

      add(:read, :boolean, null: false, default: false)
      add(:edit, :boolean, null: false, default: false)
      add(:publish, :boolean, null: false, default: false)
      add(:invite, :boolean, null: false, default: false)
    end

    create(index(:portal_permissions, [:portal_id]))
    create(index(:portal_permissions, [:role_id]))

    create(index(:portal_permissions, [:portal_id, :role_id], unique: true))
    execute("
      ALTER TABLE portal_permissions
        ADD CONSTRAINT portal_permissions_blueprint_workspace
        FOREIGN KEY (portal_id, workspace_id)
        REFERENCES portals (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")
  end

  def down do
    drop(table(:portal_permissions))
  end
end
