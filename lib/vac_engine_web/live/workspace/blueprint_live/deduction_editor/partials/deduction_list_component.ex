defmodule VacEngineWeb.Editor.DeductionListComponent do
  use Phoenix.Component

  import VacEngineWeb.Editor.DeductionComponent

  def deduction_list(assigns) do

    ~H"""
    <%= for {path, deduction} <- @deductions_with_path do %>
      <.deduction deduction={deduction} path={path} selection_path={@selection_path}/>
    <% end %>
    """
  end
end
