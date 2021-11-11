defmodule VacEngineWeb.Editor.BranchComponent do
  use Phoenix.Component

  import VacEngineWeb.IconComponent

  alias VacEngineWeb.Editor.CellComponent, as: Cell

  def render(assigns) do
    %{
      branch: branch,
      cond_columns: cond_columns,
      assign_columns: assign_columns,
      parent_path: parent_path,
      index: index
    } = assigns

    assigns =
      assign(assigns,
        renderable:
          build_renderable(
            branch,
            cond_columns,
            assign_columns,
            parent_path,
            index
          )
      )

    ~H"""
    <tr class="bg-white">
      <%= if @renderable.has_cond_cells? do %>
        <%= for {cond_cell, index} <- @renderable.cond_cells |> Enum.with_index() do %>
          <Cell.render
            is_condition={true}
            cell={cond_cell}
            parent_path={@renderable.path}
            index={index}
            row_index={@index}
            selection_path={@selection_path}
          />
        <% end %>
        <td class="bg-white text-gray-200">
          <.icon name="hero/arrow-sm-right" width="1.25rem" />
        </td>
      <% end %>
      <%= for {assign_cell, index} <- @renderable.assign_cells |> Enum.with_index() do %>
        <Cell.render
          is_condition={false}
          cell={assign_cell}
          parent_path={@renderable.path}
          index={index}
          row_index={@index}
          selection_path={@selection_path}
        />
      <% end %>
    </tr>
    """
  end

  def build_renderable(branch, cond_columns, assign_columns, parent_path, index) do
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
      assign_cells: assign_cells,
      path: parent_path ++ ["branches", index]
    }
  end
end
