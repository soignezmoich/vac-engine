defmodule VacEngineWeb.SimulationLive.MenuTemplateListComponent do
  use Phoenix.Component

  import VacEngineWeb.IconComponent

  def render(assigns) do
    ~H"""
    <div class="w-full bg-white filter drop-shadow-lg p-3">
      <div class="font-bold mb-2 border-b border-black">
        Templates
      </div>
      <%= for {template, index} <- @templates |> Enum.with_index() do %>
        <div class="link flex"
          phx-value-section={"templates"}
          phx-value-index={index}
          phx-click={"menu_select"}
          phx-target={"#simulation_editor"}
        >
          <%= template.name %>
        </div>
      <% end %>

      <form
        phx-submit={"create_template"}
        phx-target={"#simulation_editor"}
      >
        <input
          id="new_template_name"
          name="new_template_name"
          class="form-fld text-sm"
          placeholder="new template"
        />
        <button type="submit" class="btn align-top">
          <.icon name="hero/plus" width="18px" height="23px"/>
        </button>
      </form>

    </div>
    """
  end
end
