defmodule VacEngine.Processor.Deductions do
  @moduledoc false

  import Ecto.Query
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  import VacEngine.EctoHelpers
  import VacEngine.PipeHelpers

  def create_deduction(%Blueprint{} = blueprint, attrs) do
    Deduction.nested_changeset(
      %Deduction{
        blueprint_id: blueprint.id,
        workspace_id: blueprint.workspace_id
      },
      attrs,
      %{
        blueprint_id: blueprint.id,
        workspace_id: blueprint.workspace_id,
        variables: blueprint.variables,
        variable_path_index: blueprint.variable_path_index
      }
    )
    |> Repo.insert()
  end

  def update_deduction(%Deduction{} = deduction, attrs) do
    Deduction.changeset(deduction, attrs)
    |> Repo.update()
  end

  def delete_deduction(%Deduction{} = deduction) do
    dec_query =
      from(r in Deduction,
        where:
          r.position >= ^deduction.position and
            r.blueprint_id == ^deduction.blueprint_id
      )

    Multi.new()
    |> Multi.update_all(:decrement, dec_query, inc: [position: -1])
    |> Multi.delete(:deduction, deduction)
    |> transaction(:deduction)
  end

  def create_branch(%Deduction{} = deduction, attrs) do
    Branch.changeset(
      %Branch{
        blueprint_id: deduction.blueprint_id,
        workspace_id: deduction.workspace_id,
        deduction_id: deduction.id
      },
      attrs
    )
    |> Repo.insert()
  end

  def update_branch(%Branch{} = branch, attrs) do
    Branch.changeset(branch, attrs)
    |> Repo.update()
  end

  def delete_branch(%Branch{} = branch) do
    dec_query =
      from(r in Branch,
        where:
          r.position >= ^branch.position and
            r.deduction_id == ^branch.deduction_id
      )

    Multi.new()
    |> Multi.update_all(:decrement, dec_query, inc: [position: -1])
    |> Multi.delete(:branch, branch)
    |> transaction(:branch)
  end

  def create_column(%Blueprint{} = blueprint, %Deduction{} = deduction, attrs) do
    Column.nested_changeset(
      %Column{
        blueprint_id: deduction.blueprint_id,
        workspace_id: deduction.workspace_id,
        deduction_id: deduction.id
      },
      attrs,
      %{
        blueprint_id: blueprint.id,
        workspace_id: blueprint.workspace_id,
        variables: blueprint.variables,
        variable_path_index: blueprint.variable_path_index
      }
    )
    |> Repo.insert()
  end

  def update_column(%Column{} = column, attrs) do
    Column.changeset(column, attrs)
    |> Repo.update()
  end

  def delete_column(%Column{} = column) do
    dec_query =
      from(r in Column,
        where:
          r.position >= ^column.position and
            r.deduction_id == ^column.deduction_id
      )

    Multi.new()
    |> Multi.update_all(:decrement, dec_query, inc: [position: -1])
    |> Multi.delete(:column, column)
    |> transaction(:column)
  end

  def update_cell(ast, blueprint, branch, column, attrs) do
    conditions_query =
      from(c in Condition,
        where: c.column_id == ^column.id and c.branch_id == ^branch.id
      )

    assignments_query =
      from(c in Assignment,
        where: c.column_id == ^column.id and c.branch_id == ^branch.id
      )

    ctx = %{
      blueprint_id: blueprint.id,
      workspace_id: blueprint.workspace_id,
      variables: blueprint.variables,
      variable_path_index: blueprint.variable_path_index
    }

    Multi.new()
    |> Multi.run(:condition, fn repo, _ ->
      from(c in conditions_query, limit: 1)
      |> repo.one()
      |> ok()
    end)
    |> Multi.run(:assignment, fn repo, _ ->
      from(c in assignments_query, limit: 1)
      |> repo.one()
      |> ok()
    end)
    |> Multi.delete_all(:delete_conditions, conditions_query)
    |> Multi.delete_all(:delete_assignments, assignments_query)
    |> Multi.insert(:insert, fn %{condition: condition, assignment: assignment} ->
      existing_attrs =
        cond do
          condition != nil ->
            %{description: condition.description}

          assignment != nil ->
            %{description: assignment.description}

          true ->
            %{}
        end

      case column.type do
        :condition ->
          %Condition{column_id: column.id, branch_id: branch.id}
          |> Condition.nested_changeset(%{expression: ast}, ctx)
          |> Condition.changeset(existing_attrs)
          |> Condition.changeset(attrs)

        :assignment ->
          %Assignment{
            column_id: column.id,
            branch_id: branch.id
          }
          |> Assignment.nested_changeset(
            %{expression: ast, target: column.variable},
            ctx
          )
          |> Assignment.changeset(existing_attrs)
          |> Assignment.changeset(attrs)
      end
    end)
    |> transaction(:insert)
  end

  def delete_cell(branch, column) do
    conditons_query =
      from(c in Condition,
        where: c.column_id == ^column.id and c.branch_id == ^branch.id
      )

    assignments_query =
      from(c in Assignment,
        where: c.column_id == ^column.id and c.branch_id == ^branch.id
      )

    Multi.new()
    |> Multi.delete_all(:delete_conditions, conditons_query)
    |> Multi.delete_all(:delete_assignments, assignments_query)
    |> transaction(:delete_assignments)
  end

  def change_branch(branch, attrs) do
    Branch.changeset(branch, attrs)
  end

  def change_column(column, attrs) do
    Column.changeset(column, attrs)
  end

  def change_deduction(deduction, attrs) do
    Deduction.changeset(deduction, attrs)
  end
end
