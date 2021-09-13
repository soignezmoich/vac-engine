defmodule VacEngine.Repo.Migrations.CreateWorkspaces do
  use Ecto.Migration

  def change do
    create table(:workspaces) do
      add(:name, :string, size: 100, null: false)
      add(:description, :string, size: 1000)

      timestamps()
    end
  end
end
