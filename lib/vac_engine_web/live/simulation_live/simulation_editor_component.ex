defmodule VacEngineWeb.SimulationLive.SimulationEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.VariableHelpers

  alias VacEngine.Simulation
  alias VacEngine.Simulation.Case

  alias VacEngineWeb.SimulationLive.StackEditorComponent
  alias VacEngineWeb.SimulationLive.ConfigEditorComponent
  alias VacEngineWeb.SimulationLive.MenuConfigComponent
  alias VacEngineWeb.SimulationLive.MenuStackListComponent
  alias VacEngineWeb.SimulationLive.MenuTemplateListComponent
  alias VacEngineWeb.SimulationLive.TemplateEditorComponent

  @impl true
  def update(
        %{
          action: :set_selection,
          selected_type: new_selected_type,
          selected_id: new_selected_id
        },
        socket
      ) do
    socket =
      socket
      |> assign(
        selected_type: new_selected_type,
        selected_id: new_selected_id,
        templates: Simulation.get_template_names(socket.assigns.blueprint)
      )

    {:ok, socket}
  end

  # Only used at page loading or blueprint change
  @impl true
  def update(%{id: id, blueprint: blueprint}, socket) do
    socket =
      socket
      |> assign(
        id: id,
        blueprint: blueprint,
        input_variables: blueprint.variables |> flatten_variables("input"),
        output_variables: blueprint.variables |> flatten_variables("output"),
        selected_type: nil,
        selected_id: nil,
        template_names: Simulation.get_template_names(blueprint)
      )

    {:ok, socket}
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

    socket =
      socket
      |> assign(
        selected_element: selected_element,
        action: %{type: :refresh, token: :rand.uniform()}
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("create_stack", %{"new_case_name" => name}, socket) do
    new_stack_id =
      case Simulation.create_stack(socket.assigns.blueprint, name) do
        {:ok, %{case: %Case{id: id}}} -> id
      end

    stacks = Simulation.get_stacks(socket.assigns.blueprint)

    selected_element = stacks |> Enum.find(&(&1.id == new_stack_id))

    socket =
      socket
      |> assign(
        stacks: stacks,
        selected_element: selected_element
      )

    {:noreply, socket}
  end
end
