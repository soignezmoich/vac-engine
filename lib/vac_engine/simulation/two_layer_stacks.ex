defmodule VacEngine.Simulation.BasicStacks do
  @moduledoc false

  import Ecto.Query

  alias VacEngine.Repo
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.Stack

  def delete_stack_template(stack) do
    from(l in Layer,
      join: c in assoc(l, :case),
      where: l.stack_id == ^stack.id and c.runnable == false
    )
    |> Repo.delete_all()
  end

  def get_stack_runnable_case(%Stack{} = stack) do
    stack.layers
    |> Enum.reverse()
    |> Enum.find(&(&1.case.runnable == true))
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


end
