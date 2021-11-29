defmodule VacEngineWeb.Editor.DeductionComponent do
  use Phoenix.Component

  alias VacEngineWeb.Editor.BranchComponent, as: Branch
  alias VacEngineWeb.Editor.DeductionHeaderComponent, as: DeductionHeader
  alias VacEngineWeb.Editor.CellComponent, as: Cell

  def render(assigns) do
    %{deduction: deduction, parent_path: parent_path, index: index} = assigns

    assigns =
      assign(assigns,
        renderable: build_renderable(deduction, parent_path, index)
      )

    if length(assigns.renderable.cond_columns) > 0 do
      render_full(assigns)
    else
      render_short(assigns)
    end
  end

  def render_full(assigns) do
    ~H"""
    <div class="h-4" />
    <div class="shadow-lg">
      <table class="min-w-full">
        <DeductionHeader.render
          cond_columns={@renderable.cond_columns}
          assign_columns={@renderable.assign_columns} />
        <tbody>
          <%= for {branch, index} <- @deduction.branches |> Enum.with_index() do %>
            <Branch.render
              branch={branch}
              index={index}
              parent_path={@renderable.path}
              cond_columns={@renderable.cond_columns}
              assign_columns={@renderable.assign_columns}
              selection_path={@selection_path}
            />
          <% end %>
        </tbody>
      </table>
    </div>
    <div class="h-4" />
    """
  end

  def render_short(assigns) do
    variable =
      assigns.renderable.assign_columns
      |> List.first()
      |> Map.get(:variable)
      |> Enum.join(".")

    cell =
      assigns.renderable.branches
      |> List.first()
      |> Map.get(:assignments)
      |> List.first()

    ~H"""
      <div class="my-2">
        <table>
          <tbody>
            <tr>
              <td>
                <%= variable %> =
              </td>
              <Cell.render
              is_condition={false}
              cell={cell}
              parent_path={@renderable.path ++ ["branches", 0, "assignments", 0]}
              index={0}
              row_index={0}
              selection_path={@selection_path} />
            </tr>
          </tbody>
        </table>
      </div>
    """
  end

  def build_renderable(deduction, parent_path, index) do
    %{branches: branches, columns: columns} = deduction

    cond_columns =
      columns
      |> Enum.filter(&(&1.type == :condition))

    assign_columns =
      columns
      |> Enum.filter(&(&1.type == :assignment))

    %{
      branches: branches,
      cond_columns: cond_columns,
      assign_columns: assign_columns,
      path: parent_path ++ [index]
    }
  end
end
