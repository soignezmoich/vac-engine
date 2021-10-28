defmodule VacEngineWeb.Editor.BranchRenderable do

  alias VacEngineWeb.Editor.CellRenderable

  @doc """
  Create an assignment cell renderable data from
  a blueprint assignment object and extra data.
  """
  def build(
    %{conditions: conditions, assignments: assignments},
    ordered_cond_columns,
    ordered_assign_columns,
    path,
    selected_path,
    even_row
  ) do
    %{
      condition_cells: ordered_cond_columns
        |> get_cells(conditions)
        |> Enum.map(fn condition
          -> CellRenderable.build(condition, :condition, path, selected_path, even_row)
        end),
      assignment_cells: ordered_assign_columns
        |> get_cells(assignments)
        |> Enum.map(fn assignment
          -> CellRenderable.build(assignment, :assignment, path, selected_path, even_row)
        end) # TODO add type and value to path
    }

  end

  defp get_cells(ordered_columns, source) do

    ordered_columns
      |> Enum.map(&(&1.id))
      |> Enum.map(fn column_id -> populate_cell(column_id, source) end)
  end


  defp populate_cell(column_id, candidates) do
    candidates |> Enum.find(&(&1.column_id == column_id))
  end

end
