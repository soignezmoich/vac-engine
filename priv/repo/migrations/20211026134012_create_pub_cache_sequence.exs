defmodule VacEngine.Repo.Migrations.CreatePubCacheSequence do
  use Ecto.Migration

  def up do
    execute("CREATE SEQUENCE pub_cache_blueprints_version START 1")
    execute("CREATE SEQUENCE pub_cache_api_keys_version START 1")
  end

  def down do
    execute("DROP SEQUENCE pub_cache_blueprints_version")
    execute("DROP SEQUENCE pub_cache_api_keys_version")
  end
end
