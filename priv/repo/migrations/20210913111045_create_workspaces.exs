defmodule VacEngine.Repo.Migrations.CreateWorkspaces do
  use Ecto.Migration

  def change do
    create table(:workspaces) do
      timestamps()

      add(:name, :string, size: 100, null: false)
      add(:description, :string, size: 1000)
    end
  end
end
