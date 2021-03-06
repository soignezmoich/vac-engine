defmodule VacEngine.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      timestamps()

      add(:name, :string, size: 100, null: false)
      add(:description, :string, size: 1000)
      add(:email, :string, size: 100, null: false)
      add(:phone, :string, size: 100)
      add(:encrypted_password, :string, size: 200)
      add(:totp_secret, :string, size: 1000)
    end

    create(index(:users, [:email], unique: true))
  end
end
