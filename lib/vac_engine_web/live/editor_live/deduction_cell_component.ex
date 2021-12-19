defmodule VacEngineWeb.EditorLive.DeductionCellComponent do
  use VacEngineWeb, :live_component
  import VacEngine.PipeHelpers
  import Elixir.Integer

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
        %{assigns: %{deduction: deduction, column: column, branch: branch}} =
          socket
      ) do
    selection = %{
      column: column,
      branch: branch,
      deduction: deduction
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
    {type, value, args} =
      case cell do
        %{expression: %{ast: {:var, _signature, [elems]}}}
        when is_list(elems) ->
          {"variable", "@#{elems |> Enum.join(".")}", []}

        %{expression: %{ast: {op, _signature, args}}} when is_list(args) ->
          {"operator", op, args}

        %{expression: %{ast: const}} when is_boolean(const) ->
          {"const", inspect(const), []}

        %{expression: %{ast: const}} when is_binary(const) ->
          {"const", inspect(const), []}

        %{expression: %{ast: const}} when is_number(const) ->
          {"const", inspect(const), []}

        nil ->
          {"nil", "-", []}
      end

    is_condition = column.type == :condition

    selected =
      case selection do
        %{branch: %{id: bid}, column: %{id: cid}} ->
          bid == branch.id && cid == column.id

        _ ->
          false
      end

    args =
      args
      |> Enum.map(fn
        {:var, _signature, [elems]} when is_list(elems) ->
          "@#{elems |> Enum.join(".")}"

        const ->
          inspect(const)
      end)

    args =
      case is_condition do
        true -> args |> Enum.drop(1)
        false -> args
      end

    bg_color =
      case {is_condition, value, selected} do
        {_, _, true} -> "bg-pink-600 text-white"
        {true, :is_true, _} -> "bg-green-200 font-semibold"
        {true, :is_false, _} -> "bg-red-200"
        {true, "-", _} -> "bg-cream-200"
        {true, _, _} -> "bg-yellow-200"
        {_, "true", _} -> "bg-green-200 font-semibold"
        {false, _, _} -> "bg-blue-200"
      end

    bg_opacity =
      case {selected, is_even(branch.position)} do
        {true, _} -> ""
        {false, true} -> "bg-opacity-30"
        {false, false} -> "bg-opacity-50"
      end

    cell_style =
      "#{bg_color} #{bg_opacity} px-2 py-1 clickable whitespace-nowrap"

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
      args: args,
      cell_style: cell_style,
      description: description,
      selected: selected
    }
  end
end
