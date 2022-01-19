defmodule VacEngineWeb.SimulationLive.MenuCaseItemComponent do
  use Phoenix.Component

  import VacEngine.SimulationHelpers
  import VacEngine.VariableHelpers
  import VacEngineWeb.IconComponent

  def render(assigns) do

    has_mismatch = assigns.blueprint.variables
      |> flatten_variables("output")
      |> case_mismatch?(assigns.case)


    assigns = assign(assigns,
      has_mismatch: has_mismatch,
    )

    ~H"""
    <div>
      <%= if @has_mismatch  do %>
        <div class="inline-block align-top text-red-500">
          <.icon name="hero/exclamation-circle" width="1.5rem" />
        </div>
      <% else %>
        <div class="inline-block align-top text-green-600">
          <.icon name="hero/check-circle" width="1.5rem" />
        </div>
      <% end %>
      <div class="inline-block link"
        phx-value-section={"cases"}
        phx-value-index={@index}
        phx-click={"menu_select"}
        phx-target={"#simulation_editor"}
      >
        <%= @case.name %>
      </div>
    </div>
    """
  end

end
