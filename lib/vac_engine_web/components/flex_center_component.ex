defmodule VacEngineWeb.FlexCenterComponent do
  @moduledoc false

  use VacEngineWeb, :component

  def flex_center(assigns) do
    ~H"""
    <div class="self-center flex flex-grow items-center p-4 justify-center">
      <%= render_block(@inner_block) %>
    </div>
    """
  end
end
