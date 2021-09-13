defmodule VacEngine.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      timestamps()

      add(:role_id, references(:roles, on_delete: :delete_all), null: false)

      add(:token, :string, size: 200, null: false)
      add(:expires_at, :utc_datetime)
      add(:active, :bool, null: false, default: false)
      add(:remote_ip, :inet, null: false)
      add(:client_info, :jsonb)
    end
    create(index(:sessions, [:token], unique: true))
  end
end
