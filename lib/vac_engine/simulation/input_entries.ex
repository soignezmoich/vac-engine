defmodule VacEngine.Simulation.InputEntries do
  import Ecto.Changeset
  import VacEngine.EctoHelpers

  alias Ecto.Changeset
  alias VacEngine.Repo
  alias VacEngine.Simulation.InputEntry

  def create_input_entry(kase, key, value \\ "-") do
    %InputEntry{
      case_id: kase.id,
      key: key,
      value: value,
      workspace_id: kase.workspace_id
    }
    |> change(%{})
    |> unique_constraint([:case_id, :key])
    |> Repo.insert()
  end

  def delete_input_entry(input_entry) do
    Repo.delete(input_entry)
  end

  def update_input_entry(input_entry, value) do
    input_entry
    |> InputEntry.changeset(%{value: value})
    |> Repo.update()
  end

  def validate_input_entry(%Changeset{} = changeset, variable) do
    changeset
    |> validate_required([:key, :value])
    |> validate_type(:value, variable.type)
    |> validate_in_enum(:value, Map.get(variable, :variable_enum))
  end
end
