defmodule VacEngineWeb.SimulationLive.TemplateInputEditorComponent do
  use Phoenix.Component

  import VacEngine.VariableHelpers

  alias VacEngineWeb.SimulationLive.TemplateInputVariableEditorComponent

  def render(assigns) do
    ~H"""
    <div class="w-full bg-white filter drop-shadow-lg p-3 cursor-default">
      <div class="text-lg font-bold border-b border-black">Input</div>
      <%= if is_nil(@template) do %>
        <div class="font-bold text-red-600">
        Warning: no matching template.
        </div>
      <% end %>
      <table>
        <tbody>
          <%= for variable <- @blueprint.variables |> flatten_variables("input") do %>
            <.live_component
            module={TemplateInputVariableEditorComponent}
            id={"input_entry_editor_#{variable.path}"}
            variable={variable}
            template={@template}
            blueprint={@blueprint} />
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
