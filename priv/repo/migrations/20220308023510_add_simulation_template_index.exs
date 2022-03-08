defmodule VacEngine.Repo.Migrations.AddSimulationTemplateIndex do
  use Ecto.Migration

  def change do
    create(unique_index(:simulation_templates, [:blueprint_id, :case_id]))
  end
end
