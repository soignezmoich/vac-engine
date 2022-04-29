defmodule VacEngineWeb.SimulationLive.TemplateEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.CaseNameComponent
  alias VacEngineWeb.SimulationLive.MenuTemplateItemComponent
  alias VacEngineWeb.SimulationLive.TemplateEditorComponent
  alias VacEngineWeb.SimulationLive.TemplateInputComponent

  def update(%{action: {:refresh, _token}}, socket) do
    template = Simulation.get_template(socket.assigns.template.id)
    templates_sharing_case = Simulation.get_templates_sharing_case(template)
    socket
    |> assign(
      template: template,
      target_components: make_target_components(template)
    )
    |> ok()
  end

  def update(
        %{id: id, template_id: template_id, input_variables: input_variables},
        socket
      ) do
    template = Simulation.get_template(template_id)
    socket
    |> assign(
      id: id,
      input_variables: input_variables,
      template: template,
      target_components: make_target_components(template)
    )
    |> ok()
  end

  defp make_target_components(template) do
    [
      %{
        type: TemplateEditorComponent,
        id: "template_editor_#{template.id}"
      },
      %{
        type: MenuTemplateItemComponent,
        id: "menu_template_item_#{template.id}"
      }
    ]
  end
end
