defmodule VacEngineWeb.SimulationLive.MenuCaseItemComponent do
  use Phoenix.Component

  import VacEngineWeb.IconComponent

  alias VacEngine.Simulation

  def render(assigns) do
    has_mismatch = false
    # assigns.blueprint.variables
    # |> flatten_variables("output")
    # |> case_mismatch?(assigns.case)

    case_name =
      case Simulation.get_stack_case(assigns.stack) do
        %{name: name} -> name
        _ -> "ERROR: missing name"
      end

    assigns =
      assign(assigns,
        has_mismatch: has_mismatch,
        case_name: case_name
      )

    ~H"""
    <div>
      <%= if @selected do %>
        selected
      <% end %>
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
        <%= @case_name %>
      </div>
    </div>
    """
  end
end
