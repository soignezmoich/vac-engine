defmodule VacEngineWeb.SimulationLive.ToggleEntryComponent do
  use Phoenix.Component

  import VacEngineWeb.IconComponent

  def render(assigns) do

    ~H"""
    <div class="inline-block align-bottom h-10 pt-2 overflow-y-hidden">
      <%= if (@active) do %>
        <button
        phx-click={"toggle_entry"}
        phx-value-active={"false"}
        phx-target={@target_component}
        class="text-xs text-purple-700 hover:text-purple-400">
          <.icon name={"toggle-on"} width="2rem"/>
        </button>
      <% else %>
        <button
        phx-click={"toggle_entry"}
        phx-value-active={"true"}
        phx-target={@target_component}
        class="text-xs text-purple-700 hover:text-purple-400">
          <.icon name={"toggle-off"} width="2rem"/>
        </button>
      <% end %>
    </div>
    """
  end
end
