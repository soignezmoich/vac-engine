defmodule VacEngine.Repo.Migrations.CreateGlobalPermissions do
  use Ecto.Migration

  def change do
    create table(:global_permissions) do
      timestamps()

      add(:role_id, references(:roles, on_delete: :delete_all),
        null: false
      )

      add(:workspaces, :permissions, null: false)
      add(:users, :permissions, null: false)
    end

    create(index(:global_permissions, [:role_id]))

  end
end
