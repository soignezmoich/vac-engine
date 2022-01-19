defmodule VacEngineWeb.SimulationLive.MenuCaseListComponent do
  use Phoenix.Component

  alias VacEngineWeb.SimulationLive.MenuCaseItemComponent, as: CaseItem

  def render(assigns) do
    ~H"""
    <div class="w-full bg-white filter drop-shadow-lg p-3">
      <div class="font-bold mb-2 border-b border-black">
        Cases
      </div>
      <%= for {kase, index} <- @cases |> Enum.with_index() do %>
        <CaseItem.render blueprint={@blueprint} case={kase} index={index} />
      <% end %>
    </div>
    """
  end

end
