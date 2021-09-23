defmodule VacEngineWeb.ButtonComponent do
  use Phoenix.Component

  import VacEngineWeb.FormatHelpers

  def button(assigns) do
    ~H"""
    <button class={"relative " <> @class}
         phx-click={@click}"
         phx-value-key={@key}>
      <%= @label %>
      <%= if @key == @tooltip_key do %>
        <div class="text-gray-900 absolute bg-cream-200 text-xs p-1 whitespace-nowrap
                    top-full mt-1 z-50 border border-cream-600">
          click again to confirm
        </div>
      <% end %>
    </button>
    """
  end
end

