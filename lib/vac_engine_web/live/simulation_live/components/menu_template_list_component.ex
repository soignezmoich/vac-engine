defmodule VacEngineWeb.SimulationLive.MenuTemplateListComponent do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div class="w-full bg-white filter drop-shadow-lg p-3">
      <div class="font-bold mb-2 border-b border-black">
        Templates
      </div>
      <%= for {template, index} <- @templates |> Enum.with_index() do %>
      <div class="link flex"
        phx-value-section={"templates"}
        phx-value-index={index}
        phx-click={"menu_select"}
        phx-target={"#simulation_editor"}
      >
        <%= template.name %>
      </div>
      <% end %>
    </div>
    """
  end

end
