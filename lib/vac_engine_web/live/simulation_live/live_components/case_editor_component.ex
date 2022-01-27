defmodule VacEngineWeb.SimulationLive.CaseEditorComponent do
  use VacEngineWeb, :live_component

  import Ecto.Changeset

  alias VacEngine.Simulation
  alias VacEngine.Simulation.Case

  alias VacEngineWeb.SimulationLive.CaseInputEditorComponent, as: InputEditor
  alias VacEngineWeb.SimulationLive.CaseOutputEditorComponent, as: OutputEditor
  alias VacEngineWeb.SimulationLive.SimulationEditorComponent

  def update(assigns, socket) do

    data = case assigns.stack.layers |> Enum.find(&(&1.position == 1)) do
      nil -> %{case_id: nil}
      layer -> %{case_id: layer.case_id}
    end

    types = %{case_id: :integer}

    changeset = {data, types} |> cast(%{}, Map.keys(types))

    kase =
      case Simulation.get_stack_case(assigns.stack) do
        %Case{} = kase -> kase
        _ -> nil
      end

    template =
      case Simulation.get_stack_template_case(assigns.stack) do
        %Case{} = template -> template
        _ -> nil
      end

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(
        changeset: changeset,
        case: kase,
        template: template,
      )
    }
  end

  def extract_template(kase, templates) do
    templates |> Enum.find(&(&1.name == kase.template))
  end

  def handle_event("set_template", params, socket) do

    {template_id, _} = params["layer"]["case_id"]
                       |> Integer.parse()

    Simulation.set_stack_template(socket.assigns.stack, template_id)

    stack = socket.assigns.stack
    blueprint = socket.assigns.blueprint

    send_update(SimulationEditorComponent,
      id: "simulation_editor",
      selected_element: stack,
      blueprint: blueprint,
      templates: Simulation.get_templates(blueprint),
      action: "choose-template-#{template_id}"
    )


    {:noreply, socket}
  end
end
