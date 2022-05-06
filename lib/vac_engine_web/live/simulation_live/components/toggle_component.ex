defmodule VacEngineWeb.SimulationLive.ToggleComponent do
  @moduledoc false

  use Phoenix.Component

  import VacEngineWeb.IconComponent

  def render(assigns) do
    ~H"""
    <div class="mt-1 -mb-1 text-blue-600">
      <%= if (@active) do %>
        <button
        phx-click={@toggle_action}
        phx-value-active={"false"}
        phx-target={@target_component}
        class="hover:opacity-70">
          <.icon name={"toggle-on"} width="30px"/>
        </button>
      <% else %>
        <button
        phx-click={@toggle_action}
        phx-value-active={"true"}
        phx-target={@target_component}
        class="hover:opacity-70">
          <.icon name={"toggle-off"} width="30px"/>
        </button>
      <% end %>
    </div>
    """
  end
end
