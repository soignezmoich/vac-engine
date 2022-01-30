defmodule VacEngineWeb.SimulationLive.TemplateInputComponent do
  use VacEngineWeb, :live_component

  import VacEngine.VariableHelpers

  alias VacEngineWeb.SimulationLive.TemplateInputVariableComponent

  # def render(assigns) do
  #   ~H"""
  #   <div class="w-full bg-white filter drop-shadow-lg p-3 cursor-default overflow-x-auto">
  #     <div class="text-lg font-bold border-b border-black">Input</div>
  #     <%= if is_nil(@template) do %>
  #       <div class="font-bold text-red-600">
  #       Warning: no matching template.
  #       </div>
  #     <% end %>
  #     <div class="table">
  #     </div>
  #   </div>
  #   """
  # end
end
