defmodule VacEngineWeb.SimulationLive.TemplateEditorComponent do
  @moduledoc false

  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias VacEngine.Simulation
  alias VacEngine.Simulation.Templates
  alias VacEngineWeb.SimulationLive.CaseNameComponent
  alias VacEngineWeb.SimulationLive.MenuTemplateItemComponent
  alias VacEngineWeb.SimulationLive.TemplateEditorComponent
  alias VacEngineWeb.SimulationLive.TemplateInputComponent

  def update(%{action: {:refresh, _token}}, socket) do
    template = socket.assigns.template

    socket
    |> load_template(template.id)
    |> ok()
  end

  def update(
        %{id: id, template_id: template_id, input_variables: input_variables},
        socket
      ) do
    socket
    |> assign(id: id, input_variables: input_variables)
    |> load_template(template_id)
    |> ok()
  end

  def handle_event("duplicate_case", _params, socket) do
    template = socket.assigns.template
    new_name = "#{template.case.name}-b#{template.blueprint_id}"
    Templates.fork_template_case(template, new_name)

    send_update(MenuTemplateItemComponent,
      id: "menu_template_item_#{template.id}",
      action: {:refresh, new_name}
    )

    socket
    |> load_template(template.id)
    |> noreply()
  end

  defp load_template(socket, template_id) do
    template = Simulation.get_template(template_id)

    templates_sharing_case =
      Simulation.get_blueprints_sharing_template_case(template)

    socket
    |> assign(
      template: template,
      templates_sharing_case: templates_sharing_case,
      shared_case?: Enum.count(templates_sharing_case) > 0,
      target_components: make_target_components(template)
    )
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
