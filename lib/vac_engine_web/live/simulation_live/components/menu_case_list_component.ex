defmodule VacEngineWeb.SimulationLive.MenuCaseListComponent do
  use Phoenix.Component

  import VacEngineWeb.IconComponent

  alias VacEngineWeb.SimulationLive.MenuCaseItemComponent, as: CaseItem

  def render(assigns) do
    ~H"""
    <div class="w-full bg-white filter drop-shadow-lg p-3">
      <div class="font-bold mb-2 border-b border-black">
        Cases
      </div>
      <%= for {stack, index} <- @stacks |> Enum.with_index() do %>
        <CaseItem.render stack={stack} index={index} selected={stack == @selected_element} />
      <% end %>

      <form
        phx-submit={"create_stack"}
        phx-target={"#simulation_editor"}
      >
        <input
          id="new_case_name"
          name="new_case_name"
          class="form-fld text-sm"
          placeholder="new case"
        />
        <button type="submit" class="btn align-top">
          <.icon name="hero/plus" width="18px" height="23px"/>
        </button>
      </form>

      <%# IO.inspect(@stacks |> Enum.map(&(&1.layers))) %>
      <%# IO.inspect(@selected_element.layers) %>
    </div>
    """
  end
end
