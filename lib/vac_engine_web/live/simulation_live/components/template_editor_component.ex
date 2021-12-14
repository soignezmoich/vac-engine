defmodule VacEngineWeb.SimulationLive.TemplateEditorComponent do
  use Phoenix.Component

  alias VacEngineWeb.SimulationLive.TemplateInputEditorComponent, as: InputEditor

  def render(assigns) do
    ~H"""
      <div class="m-3">
        <div class="text-2xl font-bold mb-4">Template: <%= @template.name %></div>
        <div class="grid sm:grid-cols-1 2xl:grid-cols-2 gap-3">
          <InputEditor.render blueprint={@blueprint} template={@template} />
        </div>
      </div>
    """
  end

end
