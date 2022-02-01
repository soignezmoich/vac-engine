defmodule VacEngineWeb.EditorLive.DeductionCellComponent do
  use VacEngineWeb, :live_component
  import VacEngine.PipeHelpers
  import Elixir.Integer
  alias VacEngine.Processor.Ast

  alias VacEngineWeb.EditorLive.DeductionListComponent
  alias VacEngineWeb.EditorLive.DeductionInspectorComponent

  @impl true
  def update(
        %{
          column: column,
          branch: branch,
          cell: cell,
          selection: selection
        } = assigns,
        socket
      ) do
    socket
    |> assign(
      build_renderable(
        branch,
        column,
        cell,
        selection
      )
    )
    |> assign(assigns)
    |> ok()
  end

  @impl true
  def handle_event(
        "select",
        _,
        %{
          assigns: %{
            selected: true
          }
        } = socket
      ) do
    send_update(DeductionListComponent,
      id: "deduction_list",
      action: {:select, nil}
    )

    send_update(DeductionInspectorComponent,
      id: "deduction_inspector",
      action: {:select, nil}
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "select",
        _,
        %{
          assigns: %{
            deduction: deduction,
            column: column,
            branch: branch,
            cell: cell
          }
        } = socket
      ) do
    selection = %{
      column: column,
      branch: branch,
      deduction: deduction,
      cell: cell
    }

    send_update(DeductionListComponent,
      id: "deduction_list",
      action: {:select, selection}
    )

    send_update(DeductionInspectorComponent,
      id: "deduction_inspector",
      action: {:select, selection}
    )

    {:noreply, socket}
  end

  def build_renderable(
        branch,
        column,
        cell,
        selection
      ) do
    is_condition = column.type == :condition

    {type, ast, value} =
      case cell do
        %{expression: %{ast: ast}} ->
          {Ast.node_type(ast), ast, Ast.describe(ast)}

        nil ->
          {nil, nil, "-"}
      end

    selected =
      case selection do
        %{branch: %{id: bid}, column: %{id: cid}} ->
          bid == branch.id && cid == column.id

        _ ->
          false
      end

    bg_color =
      case {is_condition, ast, selected} do
        {_, {:is_true, _, _}, true} -> "bg-pink-600 text-white font-semibold"
        {_, true, true} -> "bg-pink-600 text-white font-semibold"
        {_, _, true} -> "bg-pink-600 text-white"
        {true, {:is_true, _, _}, _} -> "bg-green-200 font-semibold"
        {true, {:is_false, _, _}, _} -> "bg-red-200"
        {true, nil, _} -> "bg-cream-200"
        {true, _, _} -> "bg-yellow-200"
        {_, true, _} -> "bg-green-200 font-semibold"
        {false, _, _} -> "bg-blue-200"
      end

    bg_opacity =
      case {selected, is_even(branch.position)} do
        {true, _} -> ""
        {false, true} -> "bg-opacity-30"
        {false, false} -> "bg-opacity-50"
      end

    cell_style =
      "#{bg_color} #{bg_opacity} table-cell px-2 py-1 clickable whitespace-nowrap"

    description =
      case {is_condition, cell} do
        {false, %{description: non_empty}}
        when is_binary(non_empty) and non_empty != "" ->
          "(#{non_empty})"

        _ ->
          ""
      end

    %{
      column: column,
      type: type,
      value: value,
      cell_style: cell_style,
      description: description,
      selected: selected
    }
  end
end
