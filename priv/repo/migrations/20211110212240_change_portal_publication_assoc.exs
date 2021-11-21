defmodule VacEngine.Repo.Migrations.ChangePortalPublicationAssoc do
  use Ecto.Migration

  def up do
    drop(index(:publications, [:blueprint_id_workspace_id_portal_id]))

    alter table(:portals) do
      add(:blueprint_id, references(:blueprints, on_delete: :restrict))
    end

    execute("UPDATE portals p set blueprint_id = (
      SELECT blueprint_id from publications where portal_id = p.id and
      deactivated_at is null
      )")
  end
end
