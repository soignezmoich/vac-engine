defmodule VacEngineWeb.ButtonComponent do
  @moduledoc """
  A button with click confirmation capabilities.

  (Uses a client side script hook)
  """
  use VacEngineWeb, :component

  def button(assigns) do
    attrs =
      Map.get(assigns, :values, [])
      |> Enum.map(fn {k, v} -> {"phx-value-#{k}", v} end)

    assigns = assign(assigns, :attrs, attrs)

    ~H"""
    <button class={"relative " <> @class}
         {@attrs}
         id={Map.get(assigns, :id)}
         type={Map.get(assigns, :type)}
         phx-target={Map.get(assigns, :target)}
         phx-hook={if Map.has_key?(assigns, :id) do "confirmClick" end}
         phx-click={@click} >
      <%= @label %>
      <%= if Map.get(assigns, :confirm) do %>
        <div class="text-gray-900 absolute bg-cream-200 text-xs p-1 whitespace-nowrap
                    top-full mt-1 z-50 border border-cream-600 hidden
                    font-normal"
                    phx-update="ignore"
                    data-confirm>
          click again to confirm
        </div>
      <% end %>
    </button>
    """
  end
end
