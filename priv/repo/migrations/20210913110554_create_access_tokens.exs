defmodule VacEngine.Repo.Migrations.CreateAccessTokens do
  use Ecto.Migration

  def up do
    execute("CREATE TYPE access_token_type AS ENUM
      (
        'api_key',
        'refresh',
        'access'
      )")

    create table(:access_tokens) do
      timestamps()

      add(:role_id, references(:roles, on_delete: :delete_all), null: false)

      add(:secret, :string, size: 200, null: false)
      add(:expires_at, :utc_datetime)
      add(:type, :access_token_type)
    end

    create(index(:access_tokens, [:expires_at]))
    create(index(:access_tokens, [:role_id]))
    create(index(:access_tokens, [:type]))
    create(index(:access_tokens, [:type, :role_id]))
    create(index(:access_tokens, [:secret], unique: true))
  end

  def down do
    drop(table(:access_tokens))
    execute("DROP TYPE access_token_type")
  end
end
