defmodule VacEngineWeb.Editor.CellComponent do
  use Phoenix.Component

  import Elixir.Integer

  def render(assigns) do
    %{
      is_condition: is_condition,
      cell: cell,
      parent_path: parent_path,
      index: index,
      row_index: row_index
    } = assigns

    assigns =
      assign(assigns,
        renderable:
          build_renderable(is_condition, cell, parent_path, index, row_index)
      )

    ~H"""
    <td class={@renderable.cell_style} phx-value-path={@renderable.dot_path} phx-click={"select_cell"}>
      <%= @renderable.value %><%= if (@renderable.type == "operator") do %>(<%= @renderable.args |> Enum.join(", ") %>)<% end %>
      &nbsp;
      <%= @renderable.description %>
    </td>
    """
  end

  def build_renderable(is_condition, cell, parent_path, index, row_index) do
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

    conditions_or_assignments =
      if is_condition do
        "conditions"
      else
        "assignments"
      end

    dot_path =
      (parent_path ++ [conditions_or_assignments, index])
      |> Enum.join(".")

    # assigns.selection_path == dot_path
    selected = false

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
        # {_, _, true} -> "bg-pink-600 text-white"
        {true, :is_true, _} -> "bg-green-200 font-semibold"
        {true, :is_false, _} -> "bg-red-200"
        {true, "-", _} -> "bg-cream-200"
        {true, _, _} -> "bg-yellow-200"
        {_, "true", _} -> "bg-green-200 font-semibold"
        {false, _, _} -> "bg-blue-200"
      end

    bg_opacity =
      case {selected, is_even(row_index)} do
        # {true, _} -> ""
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
