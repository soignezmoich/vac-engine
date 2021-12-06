defmodule VacEngine.Repo.Migrations.AddVariablesIndex do
  use Ecto.Migration

  def up do
    execute(
      "CREATE UNIQUE INDEX variables_blueprint_id_name_index ON variables (name, blueprint_id) WHERE parent_id IS NULL;"
    )
  end
end
