defmodule VacEngineWeb.Editor.DeductionComponent do
  use Phoenix.Component

  alias VacEngineWeb.Editor.BranchComponent, as: Branch
  alias VacEngineWeb.Editor.DeductionHeaderComponent, as: DeductionHeader

  def render(assigns) do
    %{deduction: deduction, parent_path: parent_path, index: index} = assigns

    assigns =
      assign(assigns,
        renderable: build_renderable(deduction, parent_path, index)
      )

    ~H"""
    <div class="shadow-lg">
      <table class="min-w-full">
        <DeductionHeader.render
          cond_columns={@renderable.cond_columns}
          target_columns={@renderable.target_columns} />
        <tbody>
          <%= for {branch, index} <- @deduction.branches |> Enum.with_index() do %>
            <Branch.render
              branch={branch}
              index={index}
              parent_path={@renderable.path}
              cond_columns={@renderable.cond_columns}
              target_columns={@renderable.target_columns}
              selection_path={@selection_path} />
          <% end %>
        </tbody>
      </table>
    </div>
    <div class="h-8" />
    """
  end

  def build_renderable(deduction, parent_path, index) do
    %{branches: branches, columns: columns} = deduction

    cond_columns =
      columns
      |> Enum.filter(&(&1.type == :condition))

    target_columns =
      columns
      |> Enum.filter(&(&1.type == :assignment))

    %{
      branches: branches,
      cond_columns: cond_columns,
      target_columns: target_columns,
      path: parent_path ++ [index]
    }
  end
end
