defmodule VacEngineWeb.EditorLive.DeductionListComponent do
  use Phoenix.Component

  alias VacEngineWeb.EditorLive.DeductionComponent, as: Deduction

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
