defmodule VacEngineWeb.EditorLive.DeductionBranchComponent do
  use VacEngineWeb, :live_component
  import VacEngine.PipeHelpers

  alias VacEngineWeb.EditorLive.DeductionCellComponent

  @impl true
  def update(
        %{
          branch: branch,
          cond_columns: cond_columns,
          assign_columns: assign_columns,
          path: path,
          selected_path: selected_path
        },
        socket
      ) do
    socket
    |> assign(
      build_renderable(
        branch,
        cond_columns,
        assign_columns
      )
    )
    |> assign(path: path, branch: branch, selected_path: selected_path)
    |> ok()
  end

  def build_renderable(branch, cond_columns, assign_columns) do
    %{conditions: conditions, assignments: assignments} = branch

    cond_cells =
      cond_columns
      |> Enum.map(fn column ->
        Enum.find(conditions, &(&1.column_id == column.id))
      end)

    assign_cells =
      assign_columns
      |> Enum.map(fn column ->
        Enum.find(assignments, &(&1.column_id == column.id))
      end)

    has_cond_cells? = length(cond_cells) > 0

    %{
      has_cond_cells?: has_cond_cells?,
      cond_cells: cond_cells,
      assign_cells: assign_cells
    }
  end
end
