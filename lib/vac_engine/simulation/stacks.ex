defmodule VacEngine.Simulation.Stacks do

  import Ecto.Changeset
  import Ecto.Query

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
  end

  def create_stack(%Blueprint{} = blueprint, attrs \\ %{}) do
    Stack.nested_changeset(
      %Stack{},
      attrs,
      %{blueprint_id: blueprint.id, workspace_id: blueprint.workspace_id}
    )
    |> Repo.insert()
  end

  def delete_stack(stack_id) do
    stack = Repo.get(Stack, stack_id)
    Repo.delete(stack)
  end

  def filter_stacks_by_blueprint(query, blueprint) do
    from(b in query, where: b.blueprint_id == ^blueprint.id)
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

  def get_stack(stack_id, queries) do
    Stack
    |> queries.()
    |> Repo.get(stack_id)
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

  def list_stacks(queries) do
    Stack
    |> queries.()
    |> Repo.all()
  end

  def load_stack_layers(query) do
    layer_query =
      from(l in Layer,
        order_by: l.position,
        preload: :case
      )

    from(b in query, preload: [layers: ^layer_query])
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
