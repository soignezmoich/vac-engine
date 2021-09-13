defmodule VacEngine.Repo.Migrations.CreatePermissionsType do
  use Ecto.Migration

  def up do
    execute("CREATE TYPE permissions AS
      (
        read boolean,
        write boolean,
        delete boolean,
        delegate boolean
      )")
  end

  def down do
    execute("DROP TYPE permissions")
  end
end
