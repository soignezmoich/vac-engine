defmodule VacEngine.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def up do
    execute("CREATE TYPE role_type AS ENUM
      (
        'user',
        'link',
        'api'
      )")

    create table(:roles) do
      timestamps()

      add(:user_id, references(:users, on_delete: :restrict))
      add(:parent_id, references(:roles, on_delete: :restrict))

      add(:type, :role_type, null: false)
      add(:active, :bool, null: false, default: false)
      add(:description, :string, size: 1000)
    end

    create(index(:roles, [:user_id]))

    alter table(:users) do
      add(:role_id, references(:roles, on_delete: :restrict))
    end
    create(index(:users, [:role_id]))

  end

  def down do
    alter table(:users) do
      remove(:role_id)
    end
    drop(table(:roles))
    execute("DROP TYPE role_type")
  end

end
