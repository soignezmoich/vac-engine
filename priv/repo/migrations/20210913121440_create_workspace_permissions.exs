defmodule VacEngine.Repo.Migrations.CreateWorkspacePermissions do
  use Ecto.Migration

  def change do
    create table(:workspace_permissions) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:role_id, references(:roles, on_delete: :delete_all), null: false)

      add(:read, :boolean, null: false, default: false)
      add(:edit, :boolean, null: false, default: false)
      add(:publish, :boolean, null: false, default: false)
      add(:invite, :boolean, null: false, default: false)
    end

    create(index(:workspace_permissions, [:workspace_id]))
    create(index(:workspace_permissions, [:role_id]))

    create(
      index(:workspace_permissions, [:workspace_id, :role_id], unique: true)
    )
  end
end
