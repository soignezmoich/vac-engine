defmodule VacEngineWeb.EditorLive.DeductionComponent do
  use VacEngineWeb, :live_component
  import VacEngine.PipeHelpers
  alias VacEngineWeb.EditorLive.DeductionCellComponent
  alias VacEngineWeb.EditorLive.DeductionHeaderComponent
  alias VacEngineWeb.EditorLive.DeductionBranchComponent
  import VacEngineWeb.EditorLive.DeductionMacros

  @impl true
  def update(
        %{deduction: deduction, path: path, selected_path: selected_path},
        socket
      ) do
    socket
    |> assign(build_renderable(deduction, path, selected_path))
    |> assign(deduction: deduction, path: path, selected_path: selected_path)
    |> ok()
  end

  handle_select_event()

  def build_renderable(deduction, path, selected_path) do
    %{branches: branches, columns: columns} = deduction

    cond_columns =
      columns
      |> Enum.filter(&(&1.type == :condition))

    assign_columns =
      columns
      |> Enum.filter(&(&1.type == :assignment))

    selected =
      case selected_path do
        nil ->
          false

        list ->
          List.starts_with?(list, path)
      end

    {render_type, short_variable, short_cell} =
      cond do
        Enum.count(assign_columns) > 0 and Enum.count(cond_columns) > 0 ->
          {:full, nil, nil}

        Enum.count(assign_columns) == 1 and Enum.count(cond_columns) == 0 ->
          {:short,
           assign_columns
           |> List.first()
           |> Map.get(:variable)
           |> Enum.join("."),
           branches
           |> List.first()
           |> Map.get(:assignments)
           |> List.first()}

        true ->
          {:empty, nil, nil}
      end

    %{
      selected?: selected,
      branches: branches,
      cond_columns: cond_columns,
      assign_columns: assign_columns,
      render_type: render_type,
      short_variable: short_variable,
      short_cell: short_cell
    }
  end
end
