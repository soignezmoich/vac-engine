defmodule VacEngineWeb.EditorLive.DeductionCellComponent do
  use VacEngineWeb, :live_component
  import VacEngine.PipeHelpers
  import Elixir.Integer

  alias VacEngineWeb.EditorLive.DeductionListComponent
  alias VacEngineWeb.EditorLive.DeductionInspectorComponent
  import VacEngineWeb.EditorLive.DeductionMacros

  @impl true
  def update(
        %{
          is_condition: is_condition,
          cell: cell,
          path: path,
          selected_path: selected_path
        },
        socket
      ) do
    socket
    |> assign(
      build_renderable(
        is_condition,
        cell,
        path,
        selected_path
      )
    )
    |> assign(path: path)
    |> ok()
  end

  handle_select_event()

  def build_renderable(
        is_condition,
        cell,
        path,
        selected_path
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

    dot_path = path |> Enum.join(".")

    selected =
      case selected_path do
        nil ->
          false

        list ->
          List.starts_with?(list, path)
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

    [_, _, _, row_index | _] = path

    bg_opacity =
      case {selected, is_even(row_index)} do
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
      type: type,
      value: value,
      args: args,
      cell_style: cell_style,
      dot_path: dot_path,
      description: description,
      selected: selected
    }
  end
end
