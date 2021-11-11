defmodule VacEngineWeb.Editor.DeductionListComponent do
  use Phoenix.Component

  alias VacEngineWeb.Editor.DeductionComponent, as: Deduction

  def render(assigns) do
    ~H"""
    <%= for {deduction, index} <- @deductions |> Enum.with_index() do %>
      <Deduction.render
        deduction={deduction}
        parent_path={["deductions"]}
        index={index}
        selection_path={@selection_path}
      />
    <% end %>
    """
  end
end
