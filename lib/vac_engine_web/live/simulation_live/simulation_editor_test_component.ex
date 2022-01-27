defmodule VacEngineWeb.SimulationLive.SimulationEditorTestComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.SimulationEditorTestStackComponent

  @impl true
  def update(%{blueprint: blueprint}, socket) do
    stacks =
      Simulation.list_stacks(fn q ->
        q
        |> Simulation.filter_stacks_by_blueprint(blueprint)
        |> Simulation.load_stack_layers()
      end)

    {:ok, assign(socket, stacks: stacks)}
  end

  @impl true
  def update(_assigns, socket) do
    {:ok, socket}
  end
end
