defmodule VacEngine.Processor.Variables do
  @moduledoc false

  import Ecto.Query
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Meta
  import VacEngine.EctoHelpers, only: [transaction: 2]

  def create_variable(%Blueprint{} = parent, attrs) do
    Variable.create_changeset(%Variable{}, attrs, create_context(parent))
    |> insert_variable()
  end

  def create_variable(%Variable{} = parent, attrs) do
    Variable.create_changeset(
      %Variable{parent_id: parent.id},
      attrs,
      create_context(parent)
    )
    |> insert_variable()
  end

  def change_variable(var_or_changeset, attrs) do
    # TODO no expression casting (default value)
    Variable.changeset(var_or_changeset, attrs)
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

  defp insert_variable(changeset) do
    changeset
    |> Repo.insert_or_update()
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
end
