defmodule VacEngineWeb.Editor.BranchComponent do
  use Phoenix.Component

  alias VacEngineWeb.Editor.CellComponent, as: Cell
  alias VacEngineWeb.Icons

  def render(assigns) do
    %{
      branch: branch,
      cond_columns: cond_columns,
      target_columns: target_columns,
      parent_path: parent_path,
      index: index
    } = assigns

    assigns =
      assign(assigns,
        renderable:
          build_renderable(
            branch,
            cond_columns,
            target_columns,
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
            row_index={@index} />
        <% end %>
        <td class="bg-white text-gray-200">
          <Icons.right />
        </td>
      <% end %>
      <%= for {target_cell, index} <- @renderable.target_cells |> Enum.with_index() do %>
        <Cell.render
          is_condition={false}
          cell={target_cell}
          parent_path={@renderable.path}
          index={index}
          row_index={@index} />
      <% end %>
    </tr>
    """
  end

  def build_renderable(branch, cond_columns, target_columns, parent_path, index) do
    %{conditions: conditions, assignments: assignments} = branch

    cond_cells =
      cond_columns
      |> Enum.map(fn
        %{id: column_id} ->
          {column_id, Enum.find(conditions, &(&1.column_id == column_id))}
      end)
      |> Enum.map(fn
        {column_id, %{expression: expression}} ->
          %{
            expression: expression.ast,
            path: [column_id | ["conditions" | parent_path]]
          }

        {column_id, nil} ->
          %{expression: nil, path: [column_id | ["conditions" | parent_path]]}
      end)

    target_cells =
      target_columns
      |> Enum.map(fn
        %{id: column_id} ->
          {column_id, Enum.find(assignments, &(&1.column_id == column_id))}
      end)
      |> Enum.map(fn
        {column_id, nil} ->
          %{
            expression: nil,
            description: "",
            path: [column_id | ["assignments" | parent_path]]
          }

        {column_id, a} ->
          %{
            expression: a.expression.ast,
            description: a.description,
            path: [column_id | ["assignments" | parent_path]]
          }
      end)

    has_cond_cells? = length(cond_cells) > 0

    %{
      has_cond_cells?: has_cond_cells?,
      cond_cells: cond_cells,
      target_cells: target_cells,
      path: ["branches", index]
    }
  end
end
