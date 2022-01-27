defmodule VacEngine.Processor.Advisor do
  @moduledoc false

  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Assignment
  alias Ecto.Multi
  alias VacEngine.Repo
  import Ecto.Query

  def autofix_blueprint(%Blueprint{} = br) do
    conditons_query =
      from(c in Condition,
        where: c.blueprint_id == ^br.id and is_nil(c.column_id)
      )

    assignments_query =
      from(c in Assignment,
        where: c.blueprint_id == ^br.id and is_nil(c.column_id)
      )

    Multi.new()
    |> Multi.delete_all(:delete_conditions, conditons_query)
    |> Multi.delete_all(:delete_assignments, assignments_query)
    |> Repo.transaction()
    |> case do
      {:ok, _} -> {:ok, br}
      err -> err
    end
  end

  def blueprint_issues(%Blueprint{} = br) do
    br.deductions
    |> Enum.with_index()
    |> Enum.reduce([], fn {ded, ded_idx}, issues ->
      deduction_issues(issues, ded, %{deduction: ded, deduction_index: ded_idx})
    end)
  end

  defp deduction_issues(issues, deduction, ctx) do
    deduction.branches
    |> Enum.with_index()
    |> Enum.reduce(issues, fn {br, br_idx}, issues ->
      ctx =
        ctx
        |> Map.put(:branch, br)
        |> Map.put(:branch_index, br_idx)

      branch_issues(issues, br, ctx)
    end)
  end

  defp branch_issues(
         issues,
         branch,
         ctx
       ) do
    issues
    |> conditions_issues(branch.conditions, ctx)
    |> assignments_issues(branch.assignments, ctx)
  end

  defp conditions_issues(
         issues,
         conditions,
         %{deduction_index: ded_idx, branch_index: br_idx}
       ) do
    conditions
    |> Enum.with_index()
    |> Enum.reduce(issues, fn {c, c_idx}, issues ->
      if is_nil(c.column_id) do
        err = "Condition #{ded_idx}.#{br_idx}.#{c_idx} has no column"
        [err | issues]
      else
        issues
      end
    end)
  end

  defp assignments_issues(
         issues,
         assignments,
         %{deduction_index: ded_idx, branch_index: br_idx}
       ) do
    assignments
    |> Enum.with_index()
    |> Enum.reduce(issues, fn {c, c_idx}, issues ->
      if is_nil(c.column_id) do
        err = "Assignment #{ded_idx}.#{br_idx}.#{c_idx} has no column"
        [err | issues]
      else
        issues
      end
    end)
  end

  def blueprint_stats(%Blueprint{} = br) do
    %{
      variables: variables_stats(br),
      logic: logic_stats(br)
    }
  end

  defp variables_stats(%Blueprint{} = br) do
    br.variable_id_index
    |> Enum.reduce(
      %{input: 0, output: 0, intermediate: 0},
      fn {_id, var},
         %{input: input, output: output, intermediate: intermediate} ->
        cond do
          Variable.input?(var) ->
            %{input: input + 1, output: output, intermediate: intermediate}

          Variable.output?(var) ->
            %{input: input, output: output + 1, intermediate: intermediate}

          true ->
            %{input: input, output: output, intermediate: intermediate + 1}
        end
      end
    )
  end

  defp logic_stats(%Blueprint{} = br) do
    br.deductions
    |> Enum.reduce(
      %{deduction: 0, branch: 0, column: 0, assignment: 0, condition: 0},
      fn deduction, %{deduction: n} = acc ->
        acc
        |> count_branches(deduction.branches)
        |> count_columns(deduction.columns)
        |> Map.put(:deduction, n + 1)
      end
    )
  end

  defp count_branches(acc, branches) do
    branches
    |> Enum.reduce(acc, fn br,
                           %{
                             branch: branch,
                             assignment: assignment,
                             condition: condition
                           } = acc ->
      acc
      |> Map.put(:branch, branch + 1)
      |> Map.put(:assignment, Enum.count(br.assignments) + assignment)
      |> Map.put(:condition, Enum.count(br.conditions) + condition)
    end)
  end

  defp count_columns(acc, columns) do
    columns
    |> Enum.reduce(acc, fn _col, %{column: column} = acc ->
      acc
      |> Map.put(:column, column + 1)
    end)
  end
end
