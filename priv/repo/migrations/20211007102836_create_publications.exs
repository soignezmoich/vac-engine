defmodule VacEngine.Repo.Migrations.CreatePublications do
  use Ecto.Migration

  def change do
    create table(:publications) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :restrict),
        null: false
      )

      add(:blueprint_id, references(:blueprints, on_delete: :restrict),
        null: false
      )

      add(:portal_id, references(:portals, on_delete: :restrict), null: false)

      add(:activated_at, :utc_datetime)
      add(:deactivated_at, :utc_datetime)
    end

    create(
      index(:publications, [:blueprint_id, :workspace_id, :portal_id],
        unique: true
      )
    )

    create(unique_index(:publications, [:id, :workspace_id]))
    create(unique_index(:publications, [:id, :portal_id]))

    execute("
      ALTER TABLE publications
        ADD CONSTRAINT publications_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")
    execute("
      ALTER TABLE publications
        ADD CONSTRAINT publications_portal_workspace
        FOREIGN KEY (portal_id, workspace_id)
        REFERENCES portals (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")
  end
end
