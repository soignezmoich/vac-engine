defmodule VacEngineWeb.BlueprintLive.Import do
  @moduledoc """
  Blueprint import page.
  """
  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers
  import VacEngineWeb.PermissionHelpers, only: [can!: 3]

  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint
  alias VacEngineWeb.BlueprintLive.ImportComponent

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(blueprint new)a})

  @impl true
  def mount(_params, _session, %{assigns: %{workspace: workspace}} = socket) do
    can!(socket, :write_blueprints, workspace)

    changeset =
      %Blueprint{}
      |> Processor.change_blueprint()
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset)
    |> ok()
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:open_blueprint, blueprint_id}, socket) do
    workspace_id = socket.assigns.workspace.id

    socket
    |> push_redirect(
      to:
        Routes.workspace_blueprint_path(
          socket,
          :summary,
          workspace_id,
          blueprint_id
        )
    )
    |> noreply()
  end
end
