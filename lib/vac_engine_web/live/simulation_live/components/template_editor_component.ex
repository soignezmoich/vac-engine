defmodule VacEngineWeb.SimulationLive.TemplateEditorComponent do
  use Phoenix.Component

  alias VacEngineWeb.SimulationLive.TemplateInputEditorComponent

  def render(assigns) do
    IO.puts("RENDERING TemplateEditorComponent")
    ~H"""
      <div class="m-3">
        <div class="text-2xl font-bold mb-4">Template: <%= @template.name %></div>
        <div class="grid sm:grid-cols-1 2xl:grid-cols-2 gap-3">
          <TemplateInputEditorComponent.render blueprint={@blueprint} template={@template} />
        </div>
      </div>
    """
  end
end
