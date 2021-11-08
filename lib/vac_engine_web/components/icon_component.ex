defmodule VacEngineWeb.IconComponent do
  use VacEngineWeb, :component

  def icon(assigns) do
    width =
      Map.get_lazy(assigns, :width, fn ->
        Map.get(assigns, :height)
      end)

    height =
      Map.get_lazy(assigns, :height, fn ->
        Map.get(assigns, :width)
      end)

    assigns = assign(assigns, width: width, height: height)

    ~H"""
      <svg width={@width}
        height={@height}
        viewBox="0 0 100 100">
        <use href={"/icons/#{@name}.svg#icon"}></use>
      </svg>
    """
  end
end
