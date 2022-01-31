defmodule VacEngineWeb.SimulationLive.ToggleForbiddenComponent do
  use Phoenix.Component

  import VacEngineWeb.IconComponent

  def render(assigns) do
    ~H"""
    <div>
      <%= if (@forbidden) do %>
        <button
        phx-click={"toggle_entry"}
        phx-value-active={"false"}
        phx-target={@target_component}
        class="text-xs text-red-500 hover:text-red-300">
          <.icon name="hero/ban" width="1.6rem"/>
        </button>
      <% else %>
        <button
        phx-click={"toggle_entry"}
        phx-value-active={"true"}
        phx-target={@target_component}
        class="text-xs text-gray-300 hover:text-red-300">
        <.icon name="hero/ban" width="1.6rem"/>
        </button>
      <% end %>
    </div>
    """
  end
end
