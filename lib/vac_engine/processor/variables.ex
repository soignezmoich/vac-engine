defmodule VacEngine.Processor.Variables do
  @moduledoc false

  import Ecto.Query
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Binding
  alias VacEngine.Processor.BindingElement
  alias VacEngine.Processor.Meta
  import VacEngine.EctoHelpers, only: [transaction: 2]

  def create_variable(%Blueprint{} = parent, attrs) do
    ctx = create_context(parent)

    Multi.new()
    |> Multi.insert(:create, fn _ctx ->
      Variable.create_changeset(%Variable{}, attrs, ctx)
    end)
    |> Multi.update(:set_default, fn %{create: var} ->
      var
      |> Repo.preload(:default)
      |> Variable.update_default_changeset(attrs, ctx)
    end)
    |> Multi.run(:check_default, fn repo, %{set_default: var} ->
      check_default_circular_references(repo, var)
    end)
    |> transaction(:check_default)
  end

  def create_variable(%Variable{} = parent, attrs) do
    ctx = create_context(parent)

    Multi.new()
    |> Multi.insert(:create, fn _ctx ->
      Variable.create_changeset(%Variable{parent_id: parent.id}, attrs, ctx)
    end)
    |> Multi.update(:set_default, fn %{create: var} ->
      var
      |> Repo.preload(:default)
      |> Variable.update_default_changeset(attrs, %{})
    end)
    |> Multi.run(:check_default, fn repo, %{set_default: var} ->
      check_default_circular_references(repo, var)
    end)
    |> transaction(:check_default)
  end

  def change_variable(var_or_changeset, attrs) do
    Variable.changeset(var_or_changeset, attrs)
  end

  def update_variable(%Variable{} = var, attrs) do
    Multi.new()
    |> Multi.run(:blueprint, fn _repo, _ ->
      Processor.get_blueprint(var.blueprint_id, fn query ->
        query
        |> Processor.load_blueprint_variables()
      end)
      |> case do
        nil -> {:error, "no blueprint"}
        br -> {:ok, br}
      end
    end)
    |> Multi.update(:update, fn %{blueprint: br} ->
      Variable.update_changeset(var, attrs, %{
        workspace_id: br.workspace_id,
        blueprint_id: br.id,
        variable_path_index: br.variable_path_index,
        variable_id_index: br.variable_id_index
      })
    end)
    |> Multi.run(:check_default, fn repo, %{update: var} ->
      check_default_circular_references(repo, var)
    end)
    |> transaction(:check_default)
  end

  def delete_variable(%Variable{} = var) do
    Multi.new()
    |> Multi.run(:check_used, fn repo, _ ->
      Variable.used?(var.id, repo)
      |> case do
        false ->
          {:ok, true}

        _ ->
          {:error, "variable is used and cannot be deleted"}
      end
    end)
    |> Multi.delete(:delete, var)
    |> transaction(:delete)
  end

  def move_variable(
        %Variable{blueprint_id: blueprint_id} = var,
        %Variable{blueprint_id: blueprint_id} = new_parent
      ) do
    Multi.new()
    |> Multi.run(:check_parent, fn repo, _ ->
      from(r in Variable, where: r.id == ^new_parent.id, select: r.type)
      |> repo.one()
      |> Meta.container_type?()
      |> case do
        true -> {:ok, true}
        _ -> {:error, "parent is not a container"}
      end
    end)
    |> Multi.update(:update, Variable.parent_changeset(var, new_parent.id))
    |> transaction(:update)
  end

  def move_variable(
        %Variable{blueprint_id: blueprint_id} = var,
        %Blueprint{id: blueprint_id} = _new_parent
      ) do
    Multi.new()
    |> Multi.update(:update, Variable.parent_changeset(var, nil))
    |> transaction(:update)
  end

  defp create_context(%Blueprint{} = parent) do
    %{blueprint_id: parent.id, workspace_id: parent.workspace_id}
  end

  defp create_context(%Variable{} = parent) do
    %{blueprint_id: parent.blueprint_id, workspace_id: parent.workspace_id}
  end

  def variable_used?(%Variable{id: nil}), do: false

  def variable_used?(%Variable{id: id}) when is_integer(id) do
    Variable.used?(id, Repo)
  end

  def check_default_circular_references(repo, var) do
    check_default_circular_references({:ok, MapSet.new([var.id])}, repo, var.id)
    |> case do
      {:ok, _} -> {:ok, var}
      err -> err
    end
  end

  defp check_default_circular_references(result, repo, var_id) do
    variable_default_references(repo, var_id)
    |> Enum.reduce(result, fn
      reference_id, {:ok, forbid} ->
        if MapSet.member?(forbid, reference_id) do
          name =
            from(v in Variable, where: v.id == ^reference_id, select: v.name)
            |> repo.one!()

          {:error, "variable #{name} is causing a circular reference"}
        else
          check_default_circular_references(result, repo, reference_id)
        end

      _, res ->
        res
    end)
  end

  defp variable_default_references(repo, var_id) do
    from(b in Binding,
      join: e in assoc(b, :expression),
      where: e.variable_id == ^var_id
    )
    |> repo.all
    |> Enum.map(fn binding ->
      from(el in BindingElement,
        where: el.binding_id == ^binding.id,
        order_by: [desc: el.position],
        select: el.variable_id,
        limit: 1
      )
      |> repo.one!()
    end)
  end
end
