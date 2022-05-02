defmodule VacEngine.Simulation.SimpleStacks do
  @moduledoc """
  Simple stacks are stacks with only two layers:
  - one template layer at position 0
  - one runnable layer at position 1

  This is the only type of stack used in the current
  VacEngine simulation implementation.
  """

  import Ecto.Changeset
  import Ecto.Query

  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.Layers
  alias VacEngine.Simulation.Stack

  def delete_stack_template(stack) do
    from(l in Layer,
      join: c in assoc(l, :case),
      where: l.stack_id == ^stack.id and c.runnable == false
    )
    |> Repo.delete_all()
  end

  def get_stack_runnable_case(%Stack{} = stack) do
    stack
    |> get_runnable_layer()
    |> case do
      nil -> nil
      layer -> layer |> Map.get(:case)
    end
  end

  def get_stack_template_case(%Stack{} = stack) do
    stack.layers
    |> Enum.reverse()
    |> Enum.find(&(&1.case.runnable == false))
    |> case do
      nil -> nil
      layer -> layer |> Map.get(:case)
    end
  end

  def set_stack_template(stack, template_case_id) do
    layer =
      stack.layers
      |> Enum.reverse()
      |> Enum.find(&(&1.case.runnable == false))

    case layer do
      nil ->
        %Layer{
          workspace_id: stack.workspace_id,
          blueprint_id: stack.blueprint_id,
          case_id: template_case_id,
          stack_id: stack.id,
          position: 0
        }
        |> Layer.changeset()
        |> Repo.insert()

      old_layer ->
        Multi.new()

        # delete previous layer relation first
        |> Multi.delete(:delete_old_layer, old_layer)

        # create a new layer with the chosen template
        |> Multi.insert(
          :new_layer,
          %Layer{
            workspace_id: stack.workspace_id,
            blueprint_id: stack.blueprint_id,
            case_id: template_case_id,
            stack_id: stack.id,
            position: old_layer.position
          }
        )
        |> Repo.transaction()
    end
  end

  def fork_runnable_case(simple_stack, name) do
    original_case =
      get_stack_runnable_case(simple_stack)
      |> Repo.preload([:input_entries, :output_entries])

    Multi.new()
    |> Multi.insert(:new_case, fn _ ->
      ctx = %{workspace_id: original_case.workspace_id}

      Case.nested_changeset(%Case{}, Case.to_map(original_case), ctx)
      |> change(%{name: name})
    end)
    |> Multi.update_all(
      :layer,
      fn %{new_case: new_case} ->
        from(
          l in Layer,
          where:
            l.stack_id == ^simple_stack.id and l.case_id == ^original_case.id,
          update: [set: [case_id: ^new_case.id]]
        )
      end,
      []
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{new_case: new_case}} -> {:ok, new_case}
      other -> other
    end
  end

  def get_blueprints_sharing_runnable_case(%Stack{} = stack) do
    stack
    |> get_runnable_layer()
    |> Layers.get_blueprints_sharing_layer_case()
  end

  defp get_runnable_layer(%Stack{} = stack) do
    stack.layers
    |> Enum.reverse()
    |> Enum.find(&(&1.case.runnable == true))
  end
end
