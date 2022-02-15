defmodule VacEngineWeb.InfoComponent do
  use VacEngineWeb, :component

  import VacEngineWeb.IconComponent

  def info_component(assigns) do
    ~H"""
    <div class="text-xs pr-4 pl-2 py-2 border mb-4 max-w-4xl flex flex-row bg-teal-50">
      <div class="pr-1 text-teal-500">
        <.icon name="hero/information-circle" width="1.2rem" />
      </div>
      <div>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
