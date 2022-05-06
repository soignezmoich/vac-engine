defmodule VacEngineWeb.FlashComponent do
  @moduledoc false

  use VacEngineWeb, :component

  def error_flash(assigns) do
    ~H"""
    <%= if live_flash(@flash, :error) != nil do %>
      <div class="p-4 bg-error-300 text-error-800 font-bold border-2
                  border-error-500 my-4">
        <%= live_flash(@flash, :error) %>
      </div>
    <% end %>
    """
  end
end
