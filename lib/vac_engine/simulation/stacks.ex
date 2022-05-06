defmodule VacEngine.Simulation.Stacks do
  @moduledoc false

  import Ecto.Changeset
  import Ecto.Query

  import VacEngine.PipeHelpers

  alias Ecto.Multi
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Repo
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.Stack

  def create_blank_stack(blueprint, name) do
    Multi.new()
    |> Multi.insert(:case, fn _ ->
      %Case{
        workspace_id: blueprint.workspace_id,
        name: name,
        runnable: true
      }
      |> change(%{})
      |> check_constraint(:name, name: :simulation_cases_name_format)
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
    |> case do
      {:ok, %{stack: stack}} -> {:ok, stack}
      other -> other
    end
  end

  def create_stack(%Blueprint{} = blueprint, attrs \\ %{}) do
    Stack.nested_changeset(
      %Stack{},
      attrs,
      %{blueprint_id: blueprint.id, workspace_id: blueprint.workspace_id}
    )
    |> Repo.insert()
  end

  def delete_stack(%Stack{} = stack) do
    # The structure below (gather_orphaned_cases -> delete_stack -> delete_orphaned_cases) result
    # from the following facts:
    # - Cases can only be deleted if not referenced by a layer (or template), so the stack
    #   deletion must occur case deletion.
    # - The cases to delete can be retrieved more efficiently by using the stack and layers. So
    #   the orphaned cases retrieval must occur before stack deletion.
    Multi.new()
    |> gather_orphaned_cases_multi(stack)
    |> Multi.delete(:delete_stack, stack)
    |> Multi.delete_all(:delete_orphaned_cases, fn %{
                                                     gather_orphaned_cases:
                                                       orphaned_cases_ids
                                                   } ->
      from(c in Case, where: c.id in ^orphaned_cases_ids)
    end)
    |> Repo.transaction()
  end

  def delete_stack(stack_id) do
    stack = Repo.get(Stack, stack_id)
    delete_stack(stack)
  end

  defp gather_orphaned_cases_multi(multi, stack) do
    multi
    |> Multi.run(:gather_orphaned_cases, fn repo, _ ->
      from(c in Case,
        join: l1 in Layer,
        on: l1.case_id == c.id and l1.stack_id == ^stack.id,
        left_join: l2 in Layer,
        on: l2.case_id == c.id and l2.stack_id != ^stack.id,
        where: is_nil(l2.id),
        select: c.id
      )
      |> repo.all()
      |> ok()
    end)
  end

  def get_first_stack(blueprint) do
    from(s in Stack,
      where: s.blueprint_id == ^blueprint.id,
      limit: 1,
      preload: [:layers]
    )
    |> Repo.one()
  end

  def get_stack(stack_id) do
    from(s in Stack,
      where: s.id == ^stack_id,
      preload: [layers: [case: [:input_entries, :output_entries]]]
    )
    |> Repo.one()
  end

  def get_stack!(stack_id, queries) do
    Stack
    |> queries.()
    |> Repo.get!(stack_id)
  end

  def get_stack_names(blueprint) do
    layer_query =
      from(l in Layer,
        join: c in assoc(l, :case),
        where: c.runnable == true,
        order_by: [desc: l.position]
      )

    from(s in Stack,
      left_join: l in subquery(layer_query),
      on: l.stack_id == s.id,
      left_join: c in Case,
      on: l.case_id == c.id,
      where: s.blueprint_id == ^blueprint.id,
      select: {s.id, c.name}
    )
    |> Repo.all()
  end

  def get_stacks(blueprint) do
    from(s in Stack,
      where: s.blueprint_id == ^blueprint.id,
      preload: [:layers]
    )
    |> Repo.all()
  end

  def load_stack_layers_case_entries(query) do
    layer_query =
      from(l in Layer,
        order_by: l.position,
        preload: [case: [:input_entries, :output_entries]]
      )

    from(b in query, preload: [layers: ^layer_query])
  end

  def load_stack_setting(query) do
    from(b in query, preload: :setting)
  end
end
