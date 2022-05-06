defmodule VacEngineWeb.SimulationLive.ToggleForbiddenComponent do
  @moduledoc false

  use Phoenix.Component

  import VacEngineWeb.IconComponent

  def render(assigns) do
    ~H"""
    <div class="mt-1 -mb-1">
      <%= if (@forbidden) do %>
        <button
        phx-click={"toggle_forbidden"}
        phx-value-forbidden={"false"}
        phx-target={@target_component}
        class="text-xs text-red-500 hover:text-red-300">
          <.icon name="hero/ban" width="1.6rem"/>
        </button>
      <% else %>
        <button
        phx-click={"toggle_forbidden"}
        phx-value-forbidden={"true"}
        phx-target={@target_component}
        class="text-xs text-gray-300 hover:text-red-300">
        <.icon name="hero/ban" width="1.6rem"/>
        </button>
      <% end %>
    </div>
    """
  end
end
