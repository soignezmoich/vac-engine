defmodule VacEngineWeb.BlueprintLive.Edit do
  use VacEngineWeb, :live_view

  import VacEngineWeb.PermissionHelpers

  alias VacEngine.Processor
  alias VacEngineWeb.BlueprintLive.SummaryComponent
  alias VacEngineWeb.BlueprintLive.ImportComponent
  alias VacEngineWeb.EditorLive.DeductionEditorComponent
  alias VacEngineWeb.EditorLive.VariableEditorComponent
  alias VacEngineWeb.SimulationLive.SimulationEditorComponent

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(blueprint edit)a})

  @impl true
  def mount(%{"blueprint_id" => blueprint_id}, _session, socket) do
    blueprint = get_blueprint(blueprint_id, socket)

    can!(socket, :read, blueprint)

    {:ok,
     assign(socket,
       blueprint: blueprint,
       can_write: can?(socket, :write, blueprint)
     )}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply,
     assign(socket, location: [:blueprint, socket.assigns.live_action])}
  end

  @impl true
  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:update_blueprint, br}, socket) do
    br = get_blueprint(br.id, socket)
    {:noreply, assign(socket, blueprint: br)}
  end

  defp get_blueprint(id, socket) do
    if connected?(socket) do
      Processor.get_blueprint!(id, fn query ->
        query
        |> Processor.load_blueprint_active_publications()
        |> Processor.load_blueprint_inactive_publications()
        |> Processor.load_blueprint_variables()
        |> Processor.load_blueprint_full_deductions()
      end)
    else
      Processor.get_blueprint!(id)
    end
  end
end
