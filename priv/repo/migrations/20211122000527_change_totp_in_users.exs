defmodule VacEngine.Repo.Migrations.ChangeTotpInUsers do
  use Ecto.Migration

  def change do
    execute("ALTER TABLE users
      ALTER COLUMN totp_secret
      TYPE bytea USING totp_secret::bytea")
  end
end
