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

  # @impl true
  # def update(assigns, socket) do
  #   templates =
  #     Map.get(assigns, :templates) ||
  #       Simulation.get_templates(assigns.blueprint)

  #   stacks =
  #     Map.get(assigns, :stacks) || Simulation.get_stacks(assigns.blueprint)

  #   selected_element =
  #     get_updated_selected_element(
  #       Map.get(assigns, :selected_element),
  #       templates,
  #       stacks
  #     )

  #   action = assigns |> Map.get(:action) || nil

  #   socket =
  #     assign(socket,
  #       blueprint: assigns.blueprint,
  #        template_names: template_names,
  #       stacks: stacks,
  #       selected_element: selected_element,
  #       action: action
  #     )

  #   hash = :crypto.hash(:md5, :erlang.term_to_binary(socket)) |> Base.encode64()

  #   {
  #     :ok,
  #     socket
  #   }
  # end

  # def get_updated_selected_element(old_selected_element, templates, stacks) do
  #   case old_selected_element do
  #     # template
  #     %Case{id: id, runnable: false} ->
  #       IO.puts("TEMPLATE")
  #       templates |> Enum.find(&(&1.id == id))

  #     # case
  #     %Stack{id: id} ->
  #       IO.puts("STACK")
  #       stacks |> Enum.find(&(&1.id == id))

  #     # none
  #     _ ->
  #       IO.puts("NONE")
  #       stacks |> List.first()
  #   end
  # end

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

  # @impl true
  # def handle_event("create_template", %{"new_template_name" => name}, socket) do
  #   new_template_case_id =
  #     case Simulation.create_template(socket.assigns.blueprint, name) do
  #       {:ok, %{case: %Case{id: id}}} -> id
  #     end

  #   # template_names = Simulation.get_templates(socket.assigns.blueprint)

  #   # selected_element = templates |> Enum.find(&(&1.id == new_template_case_id))

  #   {:noreply,
  #    assign(socket, %{
  #       template_names: template_names,
  #      selected_element: selected_element
  #    })}
  # end

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
