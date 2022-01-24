defmodule VacEngine.Simulation do
  @moduledoc """
  Provides the model for the blueprint simulation. Simulation is useful
  to assess whether a ruleset meets the business requirements.

  Simulation is based on *cases* that describe the expected output for a given
  input.

  The content of a case can be used as a base for another case, forming a *stack*
  (technically, even a single case is part of a stack).

  Cases are created workspace-wide whereas case stacks are limited to the blueprint
  scope. This structure allows to share cases among several blueprints.
  """

  import Ecto.Query
  import Ecto.Changeset

  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.InputEntry
  alias VacEngine.Simulation.Template

  ### TEMPLATES ###

  def get_templates(blueprint) do
    from(c in Case,
      join: t in Template,
      on: t.case_id == c.id,
      where: t.blueprint_id == ^blueprint.id,
      preload: [:input_entries]
    )
    |> Repo.all()
  end

  def create_template(blueprint, name) do
    Multi.new()
    |> Multi.insert(:case, fn _ ->
      %Case{
        workspace_id: blueprint.workspace_id,
        name: name,
        runnable: false
      }
    end)
    |> Multi.insert(:template, fn %{case: kase} ->
      %Template{
        workspace_id: blueprint.workspace_id,
        blueprint_id: blueprint.id,
        case_id: kase.id
      }
    end)
    |> Repo.transaction()
  end

  def update_template(template, attrs) do
  end

  def create_input_entry(kase, key, value \\ "") do
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

  # ### CASE STACKS ###

  # def get_stacks(workspace_id, blueprint_id) do

  # end

  ### CASE EDITION ###

  # def get_cases(workspace_id) do

  # end

  # def get_stacks(workspace_id, blueprint_id) do

  # end

  # def set_simulation_time() do

  # end

  # def get_case!() do

  # end

  # def get_stack() do

  # end

  # def create_input_entry() do

  # end

  # def set_input_entry() do

  # end

  # def create_output_entry() do

  # end

  # def set_output_entry() do

  # end

  # def set_case_time() do

  # end
end
