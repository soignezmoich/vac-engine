defmodule VacEngineWeb.LoaderCardComponent do
  @moduledoc """
  A card with a loader.
  """

  use VacEngineWeb, :component

  def loader_card(assigns) do
    ~H"""
    <div class="flex items-center flex-col
      bg-white overflow-hidden shadow-md
      p-10 bg-cream-700">
      <div class="font-bold text-2xl mb-4 text-gray-100"><%= @title %></div>
      <div class="text-gray-200 flex flex-col items-center p-6">
        <svg
          width="300px"
          height="120px"
          viewBox="0 0 300 120">
          <use href="/icons/loading_spinner.svg#icon"></use>
        </svg>
      </div>
      <span class="mt-4 text-md text-gray-200"><%= @text %></span>
    </div>
    """
  end
end
