defmodule VacEngineWeb.TextCardComponent do
  use VacEngineWeb, :component

  def text_card(assigns) do
    ~H"""
    <div class="flex flex-col bg-cream-700 p-10 shadow-md items-center max-w-xs">
      <div class="font-bold text-gray-100 text-xl"><%= @title %></div>
      <div class="text-gray-200 pt-6 text-center">
        <%= @text %>
      </div>
    </div>
    """
  end
end
