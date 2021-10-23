defmodule VacEngineWeb.Workspace.BlueprintLive.Edit do
  use VacEngineWeb, :live_view

  import VacEngineWeb.PermissionHelpers, only: [can!: 3]
  import VacEngineWeb.Workspace.BlueprintLive.TabComponent

  alias VacEngine.Processor
  alias VacEngineWeb.Editor.Deductions
  alias VacEngineWeb.Editor.VariablesSection

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
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    IO.inspect("save blueprint triggered from header")
    {:noreply, socket}
  end
end
