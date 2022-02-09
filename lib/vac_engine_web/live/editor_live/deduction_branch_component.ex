defmodule VacEngineWeb.EditorLive.DeductionBranchComponent do
  use VacEngineWeb, :live_component
  import VacEngine.PipeHelpers

  alias VacEngineWeb.EditorLive.DeductionCellComponent

  @impl true
  def update(
        %{
          assign_columns: assign_columns,
          branch: branch,
          cond_columns: cond_columns,
          deduction: deduction,
          readonly: readonly,
          selection: selection
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
    |> assign(
      branch: branch,
      selection: selection,
      deduction: deduction,
      readonly: readonly
    )
    |> ok()
  end

  def build_renderable(branch, cond_columns, assign_columns) do
    %{conditions: conditions, assignments: assignments} = branch

    cond_cells =
      cond_columns
      |> Enum.map(fn column ->
        conditions
        |> Enum.find(&(&1.column_id == column.id))
        |> then(&{column, &1})
      end)

    assign_cells =
      assign_columns
      |> Enum.map(fn column ->
        assignments
        |> Enum.find(&(&1.column_id == column.id))
        |> then(&{column, &1})
      end)

    has_cond_cells? = length(cond_cells) > 0

    %{
      has_cond_cells?: has_cond_cells?,
      cond_cells: cond_cells,
      assign_cells: assign_cells
    }
  end
end
