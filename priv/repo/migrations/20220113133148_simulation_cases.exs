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

      add(:simulation_date, :naive_datetime)
    end

    create(index(:simulation_settings, [:blueprint_id]))
    create(index(:simulation_settings, [:workspace_id]))



    ### CASES ###

    create table(:simulation_cases) do
      timestamps()

      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:name, :string, size: 100, null: false)
      add(:description, :string, size: 1000)
      add(:simulated_time, :naive_datetime) # CHECK best date format?
      add(:runnable, :boolean)
    end

    create(index(:simulation_cases, [:workspace_id]))



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



    create table(:simulation_output_entries) do

      add(:case_id, references(:simulation_cases, on_delete: :delete_all),
        null: false
      )
      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )

      add(:key, :string, size: 512, null: false)
      add(:expected, :string, size: 256) # if null, the entry is forbidden
    end

    create(index(:simulation_output_entries, [:case_id]))
    create(index(:simulation_output_entries, [:workspace_id]))
    create(unique_index(:simulation_output_entries, [:case_id, :key]))



    ### STACKS ###

    create table(:simulation_stacks) do
      add(:workspace_id, references(:workspaces, on_delete: :delete_all),
        null: false
      )
      add(:blueprint_id, references(:blueprints, on_delete: :delete_all),
        null: false
      )

      add(:active, :boolean, null: false)
    end

    create(index(:simulation_stacks, [:blueprint_id]))
    create(index(:simulation_stacks, [:workspace_id]))



    ### LAYERS ###

    create table(:simulation_layers) do
      add(:blueprint_id, references(:workspaces, on_delete: :delete_all),
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
  end

  def down do
    drop(table(:simulation_layers))
    drop(table(:simulation_stacks))
    drop(table(:simulation_output_entries))
    drop(table(:simulation_input_entries))
    drop(table(:simulation_cases))
    drop(table(:simulation_settings))
  end
end
