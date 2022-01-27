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
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.OutputEntry
  alias VacEngine.Simulation.Stack
  alias VacEngine.Simulation.Template

  @case_layer_position 0
  @template_layer_position 1

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
      |> change(%{})
      |> unique_constraint([:name, :workspace_id])
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

  def create_output_entry(kase, key, expected \\ "") do
    %OutputEntry{
      case_id: kase.id,
      key: key,
      expected: expected,
      workspace_id: kase.workspace_id
    }
    |> change(%{})
    |> unique_constraint([:case_id, :key])
    |> Repo.insert()
  end

  def delete_output_entry(output_entry) do
    Repo.delete(output_entry)
  end

  
  def update_input_entry(input_entry, value) do
    input_entry
    |> InputEntry.changeset(%{value: value})
    |> Repo.update()
  end



  # ### CASE STACKS ###

  def get_stacks(blueprint) do
    from(s in Stack,
      where: s.blueprint_id == ^blueprint.id,
      preload: [:layers]
    )
    |> Repo.all()
  end

  def create_stack(blueprint, name) do
    Multi.new()
    |> Multi.insert(:case, fn _ ->
      %Case{
        workspace_id: blueprint.workspace_id,
        name: name,
        runnable: false
      }
      |> change(%{})
      |> unique_constraint([:name, :workspace_id])
    end)
    |> Multi.insert(:stack, fn _ ->
      %Stack{
        workspace_id: blueprint.workspace_id,
        blueprint_id: blueprint.id
      }
    end)
    |> Multi.insert(:layer, fn %{case: kase, stack: stack} ->
      %Layer{
        workspace_id: blueprint.workspace_id,
        blueprint_id: blueprint.id,
        case_id: kase.id,
        stack_id: stack.id,
        position: 0
      }
    end)
    |> Repo.transaction()
  end

  ### TWO LAYERS STACK GETTERS ###

  def get_stack_template_case(stack) do
    template_layer =
      stack.layers
      |> Enum.find(&(&1.position == @template_layer_position))

    case template_layer do
      nil ->
        nil

        %{case_id: case_id} ->
        from(c in Case,
          where: c.id == ^case_id,
          preload: [:input_entries]
        )
        |> Repo.one()
    end
  end

  def get_stack_case(stack) do
    case_layer =
      stack.layers
      |> Enum.find(&(&1.position == @case_layer_position))

    IO.puts("GET STACK CASE case_layer=")
    IO.inspect(case_layer)

    case case_layer do
      nil ->
        nil

      %{case_id: case_id} ->
        from(c in Case,
        where: c.id == ^case_id,
        preload: [:input_entries, :output_entries]
        )
        |> Repo.one()
        |> IO.inspect()
    end
  end

  def set_stack_template(stack, template_id) do
    # delete previous layer relation first
    layer =
      stack.layers
      |> Enum.find(&(&1.position == @template_layer_position))

    case layer do
      nil ->
        %Layer{
          workspace_id: stack.workspace_id,
          blueprint_id: stack.blueprint_id,
          case_id: template_id,
          stack_id: stack.id,
          position: 1
        }
        |> Repo.insert()

      old_layer ->
        Multi.new()
        |> Multi.delete(:delete_old_layer, old_layer)
        |> Multi.insert(
          :new_layer,
          %Layer{
            workspace_id: stack.workspace_id,
            blueprint_id: stack.blueprint_id,
            case_id: template_id,
            stack_id: stack.id,
            position: 1
          }
        )
        |> Repo.transaction()
    end

    # create a new layer with the chosen template
  end

  def variable_default_value(type, enum) do
    case {type, enum} do
      {:boolean, _} -> "false"
      {:string, nil} -> ""
      {:string, enum} -> enum |> List.first() || ""
      {:date, _} -> "2000-01-01"
      {:datetime, _} -> "2000-01-01T00:00:00"
      {:number, _} -> "0.0"
      {:integer, _} -> "0"
    end
  end

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
