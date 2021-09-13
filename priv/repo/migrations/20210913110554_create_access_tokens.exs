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
      add(:token, :string, size: 200, null: false)
      add(:role_id, references(:roles, on_delete: :delete_all), null: false)
      add(:expires_at, :utc_datetime)
      add(:type, :access_token_type)

      timestamps()
    end

    create(index(:access_tokens, [:role_id]))
    create(index(:access_tokens, [:type]))
    create(index(:access_tokens, [:type, :role_id]))
    create(index(:access_tokens, [:token], unique: true))
  end

  def down do
    drop(table(:access_tokens))
    execute("DROP TYPE access_token_type")
  end
end
