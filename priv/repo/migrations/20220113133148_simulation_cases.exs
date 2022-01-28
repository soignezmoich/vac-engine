defmodule VacEngine.Repo.Migrations.SimulationCases do
  use Ecto.Migration

  def up do
    ### SIMULATION SETTINGS ###

    create table(:simulation_settings) do
      timestamps()

      add(:blueprint_id, references(:blueprints, on_delete: :delete_all),
        null: false
      )

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:env_now, :utc_datetime)
    end

    create(unique_index(:simulation_settings, [:blueprint_id]))
    create(index(:simulation_settings, [:workspace_id]))

    # enforce same workspace for simulation settings and blueprint
    execute("
      ALTER TABLE simulation_settings
        ADD CONSTRAINT simulation_settings_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    ### CASES ###

    create table(:simulation_cases) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:name, :string, size: 100, null: false)
      add(:description, :string, size: 1000)
      add(:env_now, :utc_datetime)
      add(:runnable, :boolean, null: false)
    end

    create(index(:simulation_cases, [:workspace_id]))
    create(unique_index(:simulation_cases, [:id, :workspace_id]))

    create(
      constraint(
        :simulation_cases,
        "simulation_cases_name_format",
        check: "name ~ '^[A-Za-z][A-Za-z0-9_-]+$'"
      )
    )

    ### CASE ENTRIES ###

    create table(:simulation_input_entries) do
      add(:case_id, references(:simulation_cases, on_delete: :delete_all),
        null: false
      )

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:key, :string, size: 512, null: false)
      add(:value, :string, size: 256, null: false)
    end

    create(index(:simulation_input_entries, [:case_id]))
    create(index(:simulation_input_entries, [:workspace_id]))
    create(unique_index(:simulation_input_entries, [:case_id, :key]))

    # enforce same workspace for input entry and case
    execute("
      ALTER TABLE simulation_input_entries
        ADD CONSTRAINT simulation_input_entries_case_workspace
        FOREIGN KEY (case_id, workspace_id)
        REFERENCES simulation_cases (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    create table(:simulation_output_entries) do
      add(:case_id, references(:simulation_cases, on_delete: :delete_all),
        null: false
      )

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:key, :string, size: 512, null: false)
      # if null, the entry is forbidden
      add(:expected, :string, size: 512)
    end

    create(index(:simulation_output_entries, [:case_id]))
    create(index(:simulation_output_entries, [:workspace_id]))
    create(unique_index(:simulation_output_entries, [:case_id, :key]))

    # enforce same workspace for output entry and case
    execute("
      ALTER TABLE simulation_output_entries
        ADD CONSTRAINT simulation_output_entries_case_workspace
        FOREIGN KEY (case_id, workspace_id)
        REFERENCES simulation_cases (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    ### STACKS ###

    create table(:simulation_stacks) do
      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:blueprint_id, references(:blueprints, on_delete: :delete_all),
        null: false
      )

      add(:active, :boolean, null: false, default: true)
    end

    create(index(:simulation_stacks, [:blueprint_id]))
    create(index(:simulation_stacks, [:workspace_id]))
    create(unique_index(:simulation_stacks, [:id, :blueprint_id]))

    # enforce same workspace for stack and blueprint
    execute("
      ALTER TABLE simulation_stacks
        ADD CONSTRAINT simulation_stacks_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    ### LAYERS ###

    create table(:simulation_layers) do
      add(:blueprint_id, references(:blueprints, on_delete: :delete_all),
        null: false
      )

      add(:case_id, references(:simulation_cases, on_delete: :restrict),
        null: false
      )

      add(:stack_id, references(:simulation_stacks, on_delete: :delete_all),
        null: false
      )

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:position, :integer, null: false)
    end

    create(index(:simulation_layers, [:blueprint_id]))
    create(index(:simulation_layers, [:case_id]))
    create(index(:simulation_layers, [:stack_id]))
    create(index(:simulation_layers, [:workspace_id]))

    # enforce same blueprint for layer and stack
    execute("
      ALTER TABLE simulation_layers
        ADD CONSTRAINT simulation_layers_stack_blueprint
        FOREIGN KEY (stack_id, blueprint_id)
        REFERENCES simulation_stacks (id, blueprint_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")

    ### TEMPLATES ###

    create table(:simulation_templates) do
      add(:blueprint_id, references(:blueprints, on_delete: :delete_all),
        null: false
      )

      add(:case_id, references(:simulation_cases, on_delete: :restrict),
        null: false
      )

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )
    end

    create(index(:simulation_templates, [:blueprint_id]))
    create(index(:simulation_templates, [:case_id]))
    create(index(:simulation_templates, [:workspace_id]))

    # enforce same workspace for template and blueprint
    execute("
      ALTER TABLE simulation_templates
        ADD CONSTRAINT simulation_templates_blueprint_workspace
        FOREIGN KEY (blueprint_id, workspace_id)
        REFERENCES blueprints (id, workspace_id)
        ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
    ")
  end

  def down do
    drop(table(:simulation_templates))
    drop(table(:simulation_layers))
    drop(table(:simulation_stacks))
    drop(table(:simulation_output_entries))
    drop(table(:simulation_input_entries))
    drop(table(:simulation_cases))
    drop(table(:simulation_settings))
  end
end
