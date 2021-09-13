defmodule VacEngine.Repo.Migrations.CreateWorkspacePermissions do
  use Ecto.Migration

  def change do
    create table(:workspace_permissions) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )
      add(:role_id, references(:roles, on_delete: :delete_all),
        null: false
      )

      add(:portals, :permissions, null: false)
      add(:endpoints, :permissions, null: false)
      add(:users, :permissions, null: false)
    end

    create(index(:workspace_permissions, [:workspace_id]))
    create(index(:workspace_permissions, [:role_id]))
  end
end
