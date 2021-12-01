defmodule VacEngine.Repo.Migrations.ChangePermissions do
  use Ecto.Migration

  def up do
    alter table(:workspace_permissions) do
      remove(:read)
      remove(:edit)
      remove(:publish)
      remove(:invite)
    end

    alter table(:workspace_permissions) do
      add(:run_portals, :boolean, null: false, default: false)
      add(:read_portals, :boolean, null: false, default: false)
      add(:write_portals, :boolean, null: false, default: false)
      add(:read_blueprints, :boolean, null: false, default: false)
      add(:write_blueprints, :boolean, null: false, default: false)
    end

    alter table(:blueprint_permissions) do
      remove(:test)
      remove(:edit)
    end

    alter table(:blueprint_permissions) do
      add(:write, :boolean, null: false, default: false)
    end

    alter table(:portal_permissions) do
      remove(:edit)
      remove(:publish)
      remove(:invite)
      remove(:portal_id)
    end

    alter table(:portal_permissions) do
      add(:run, :boolean, null: false, default: false)
      add(:write, :boolean, null: false, default: false)
      add(:portal_id, references(:portals, on_delete: :delete_all), null: false)
    end
  end
end
