defmodule VacEngine.Processor.Deductions do
  @moduledoc false

  import Ecto.Query
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  import VacEngine.EctoHelpers

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
end
