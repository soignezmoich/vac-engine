defmodule VacEngineWeb.SimulationLive.SimulationEditorComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Job

  alias VacEngineWeb.SimulationLive.StackEditorComponent
  alias VacEngineWeb.SimulationLive.ConfigEditorComponent
  alias VacEngineWeb.SimulationLive.MenuConfigComponent
  alias VacEngineWeb.SimulationLive.MenuStackListComponent
  alias VacEngineWeb.SimulationLive.MenuTemplateListComponent
  alias VacEngineWeb.SimulationLive.TemplateEditorComponent

  # id: "simulation_editor",
  # action: :refres_after_delete_template,
  # template_id: template_id,

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

    if new_selected_type == :stack do
      stack = Simulation.get_stack(new_selected_id)

      stack
      |> Job.new()
      |> Simulation.queue_job()
    end

    socket =
      socket
      |> assign(
        selected_type: new_selected_type,
        selected_id: new_selected_id,
        template_names: Simulation.get_template_names(blueprint)
      )

    {:ok, socket}
  end

  # Only used at page loading or blueprint change
  @impl true
  def update(%{id: id, blueprint: blueprint}, socket) do
    {selected_type, selected_id} = get_initial_selection(blueprint)

    start_all_runner_jobs(blueprint)

    socket =
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

    {:ok, socket}
  end

  def update(%{action: :update_all_results}, socket) do
    %{blueprint: blueprint} = socket.assigns

    start_all_runner_jobs(blueprint)

    {:ok, socket}
  end

  defp start_all_runner_jobs(blueprint) do
    stacks = Simulation.get_stacks(blueprint)

    stacks
    |> Enum.map(&Job.new(&1))
    |> Enum.map(&Simulation.queue_job(&1))
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

  defp get_initial_selection(blueprint) do
    first_stack = Simulation.get_first_stack(blueprint)

    case first_stack do
      nil -> {nil, nil}
      stack -> {:stack, stack.id}
    end
  end
end
