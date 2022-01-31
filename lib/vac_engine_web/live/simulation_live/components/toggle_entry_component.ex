defmodule VacEngineWeb.SimulationLive.ToggleEntryComponent do
  use Phoenix.Component

  import VacEngineWeb.IconComponent

  def render(assigns) do
    ~H"""
    <div class="mt-1 -mb-1">
      <%= if (@active) do %>
        <button
        phx-click={"toggle_entry"}
        phx-value-active={"false"}
        phx-target={@target_component}
        class="text-purple-700 hover:text-purple-400">
          <.icon name={"toggle-on"} width="30px"/>
        </button>
      <% else %>
        <button
        phx-click={"toggle_entry"}
        phx-value-active={"true"}
        phx-target={@target_component}
        class="text-purple-700 hover:text-purple-400">
          <.icon name={"toggle-off"} width="30px"/>
        </button>
      <% end %>
    </div>
    """
  end
end
