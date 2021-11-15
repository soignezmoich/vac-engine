defmodule VacEngineWeb.ToggleComponent do
  use VacEngineWeb, :component

  import VacEngineWeb.FormatHelpers

  def toggle(assigns) do
    ~H"""
    <div class="flex border-cream-200 border cursor-pointer relative select-none"
         id={Map.get(assigns, :id)}
         phx-target={Map.get(assigns, :target)}
         phx-hook={if Map.has_key?(assigns, :id) do "confirmClick" end}
         phx-click={@click}>
      <%= if @value do %>
        <div class="w-10 bg-blue-100"></div>
        <div class="w-10 bg-blue-500 text-center font-bold text-gray-50 py-1">
          <%= format_bool(@value) %>
        </div>
      <% else %>
        <div class="w-10 bg-cream-500 text-center font-bold text-gray-100 py-1">
          <%= format_bool(@value) %>
        </div>
        <div class="w-10 bg-cream-100"></div>
      <% end %>
      <%= if Map.get(assigns, :confirm) do %>
        <div class="absolute bg-cream-200 text-xs p-1 whitespace-nowrap
                    top-full mt-1 z-50 border border-cream-600 hidden"
             phx-update="ignore"
             data-confirm>
          click again to toggle
        </div>
      <% end %>
    </div>
    """
  end

  def toggle_field(assigns) do
    ~H"""
    <div class={"flex items-center select-none #{Map.get(assigns, :class)}"}>
      <div class="font-bold mr-2"><%= @label %></div>
      <div class="relative h-8 w-20">
        <%= checkbox @form, @field, class: "border h-8 w-20" %>
        <div class="checkbox-after font-bold flex flex-stretch border h-8 w-20">
          <div class="sel bg-blue-100 items-stretch w-20 text-gray-50">
            <div class="w-10 ml-10 bg-blue-500 flex items-center justify-center">Yes</div>
          </div>
          <div class="unsel bg-cream-100 items-stretch w-20 text-gray-100">
            <div class="w-10 bg-cream-500 flex items-center justify-center">No</div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
