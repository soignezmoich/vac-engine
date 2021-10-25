defmodule VacEngineWeb.Workspace.BlueprintLive.Edit do
  use VacEngineWeb, :live_view

  import VacEngineWeb.PermissionHelpers, only: [can!: 3]

  alias VacEngine.Processor
  import VacEngineWeb.Editor.Deductions, only: [deductions: 1]
  import VacEngineWeb.Editor.VariablesSection, only: [variables_section: 1]
  alias VacEngineWeb.Workspace.BlueprintLive.SummaryComponent
  alias VacEngineWeb.Workspace.BlueprintLive.ImportComponent

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(blueprint edit)a})

  @impl true
  def mount(%{"blueprint_id" => blueprint_id}, _session, socket) do
    can!(socket, :edit, {:blueprint, blueprint_id})

    blueprint =
      if connected?(socket) do
        Processor.get_blueprint!(blueprint_id)
      else
        nil
      end

    {:ok, assign(socket, blueprint: blueprint)}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply,
     assign(socket, location: [:blueprint, socket.assigns.live_action])}
  end

  @impl true
  def handle_event("save", _params, socket) do
    IO.inspect("save blueprint triggered from header")
    {:noreply, socket}
  end

  @impl true
  def handle_info({:update_blueprint, br}, socket) do
    {:noreply, assign(socket, blueprint: br)}
  end
end
