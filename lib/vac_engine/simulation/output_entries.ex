defmodule VacEngine.Simulation.OutputEntries do
  @moduledoc false

  import Ecto.Changeset

  alias VacEngine.Repo
  alias VacEngine.Simulation
  alias VacEngine.Simulation.OutputEntry

  def create_blank_output_entry(kase, key, variable) do
    expected = Simulation.variable_default_value(variable.type, variable.enum)
    forbid = variable.type == :map

    %OutputEntry{
      case_id: kase.id,
      key: key,
      expected: expected,
      forbid: forbid,
      workspace_id: kase.workspace_id
    }
    |> change(%{})
    |> unique_constraint([:case_id, :key])
    |> Repo.insert()
  end

  def delete_output_entry(output_entry) do
    Repo.delete(output_entry)
  end

  def set_expected(%OutputEntry{} = entry, expected) do
    entry
    |> cast(%{expected: expected, forbid: false}, [:expected, :forbid])
    |> Repo.update()
  end

  def toggle_forbidden(%OutputEntry{} = entry, forbidden) do
    entry
    |> change(%{forbid: forbidden})
    |> Repo.update()
  end
end
