defmodule VacEngineWeb.SimulationLive.SimulationEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.StackEditorComponent
  alias VacEngineWeb.SimulationLive.ConfigEditorComponent
  alias VacEngineWeb.SimulationLive.MenuConfigComponent
  alias VacEngineWeb.SimulationLive.MenuStackListComponent
  alias VacEngineWeb.SimulationLive.MenuTemplateListComponent
  alias VacEngineWeb.SimulationLive.TemplateEditorComponent

  def update(
        %{
          action: :refresh_after_delete_template,
          template_id: _template_id
        },
        socket
      ) do
    update(
      %{
        action: :set_selection,
        selected_type: nil,
        selected_id: nil
      },
      socket
    )
  end

  @impl true
  def update(
        %{
          action: :set_selection,
          selected_type: new_selected_type,
          selected_id: new_selected_id
        },
        socket
      ) do
    %{blueprint: blueprint} = socket.assigns

    socket
    |> assign(
      selected_type: new_selected_type,
      selected_id: new_selected_id,
      template_names: Simulation.get_template_names(blueprint)
    )
    |> ok()
  end

  # Only used at page loading or blueprint change
  @impl true
  def update(%{id: id, blueprint: blueprint}, socket) do
    {selected_type, selected_id} = get_initial_selection(blueprint)

    socket
    |> assign(
      id: id,
      blueprint: blueprint,
      input_variables: blueprint.input_variables,
      output_variables: blueprint.output_variables,
      selected_type: selected_type,
      selected_id: selected_id,
      template_names: Simulation.get_template_names(blueprint)
    )
    |> ok()
  end

  @impl true
  def handle_event("menu_select", params, socket) do
    selected_element =
      case params do
        %{"section" => "config"} ->
          :config

        %{"section" => "templates", "index" => index} ->
          {idx, _} = Integer.parse(index)
          socket.assigns.templates |> Enum.at(idx)

        %{"section" => "cases", "index" => index} ->
          {idx, _} = Integer.parse(index)
          socket.assigns.stacks |> Enum.at(idx)
      end

    socket
    |> assign(
      selected_element: selected_element,
      action: %{type: :refresh, token: :rand.uniform()}
    )
    |> noreply()
  end

  defp get_initial_selection(blueprint) do
    first_stack = Simulation.get_first_stack(blueprint)

    case first_stack do
      nil -> {nil, nil}
      stack -> {:stack, stack.id}
    end
  end
end
