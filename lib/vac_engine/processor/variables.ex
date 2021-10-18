defmodule VacEngine.Processor.Variables do
  import Ecto.Query
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Meta
  alias VacEngine.Processor

  def create_variable(%Variable{} = parent, attrs) do
    Variable.create_changeset(
      %Variable{parent_id: parent.id},
      attrs,
      create_context(parent)
    )
    |> insert_variable()
  end

  def create_variable(%Blueprint{} = parent, attrs) do
    Variable.create_changeset(%Variable{}, attrs, create_context(parent))
    |> insert_variable()
  end

  def update_variable(%Variable{} = var, attrs) do
    Variable.update_changeset(var, attrs, %{})
    |> insert_variable()
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
    |> Repo.transaction()
    |> case do
      {:ok, %{delete: var}} ->
        blueprint = var.blueprint_id |> Processor.get_blueprint!()
        {:ok, %{blueprint: blueprint, variable: var}}

      {:error, _, msg} ->
        {:error, msg}

      err ->
        err
    end
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
    |> Repo.transaction()
    |> case do
      {:ok, %{update: var}} ->
        var_ok(var)

      {:error, _, msg} ->
        {:error, msg}
    end
  end

  def move_variable(
        %Variable{blueprint_id: blueprint_id} = var,
        %Blueprint{id: blueprint_id} = _new_parent
      ) do
    Multi.new()
    |> Multi.update(:update, Variable.parent_changeset(var, nil))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: var}} ->
        var_ok(var)

      {:error, _, msg} ->
        {:error, msg}
    end
  end

  defp insert_variable(changeset) do
    changeset
    |> Repo.insert_or_update()
    |> case do
      {:ok, var} ->
        var_ok(var)

      err ->
        err
    end
  end

  defp var_ok(var) do
    blueprint = var.blueprint_id |> Processor.get_blueprint!()
    var = Map.fetch!(blueprint.variable_id_index, var.id)
    {:ok, %{blueprint: blueprint, variable: var}}
  end

  defp create_context(%Blueprint{} = parent) do
    %{blueprint_id: parent.id, workspace_id: parent.workspace_id}
  end

  defp create_context(%Variable{} = parent) do
    %{blueprint_id: parent.blueprint_id, workspace_id: parent.workspace_id}
  end
end
