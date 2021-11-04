defmodule VacEngine.Repo.Migrations.AddLinkTokenType do
  use Ecto.Migration

  def up do
    execute("ALTER TYPE access_token_type ADD VALUE 'link' AFTER 'access';")
  end
end
