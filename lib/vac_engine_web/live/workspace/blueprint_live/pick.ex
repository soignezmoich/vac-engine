defmodule VacEngineWeb.Workspace.BlueprintLive.Pick do
  use VacEngineWeb, :live_view

  import VacEngineWeb.BlueprintsListComponent

  alias VacEngine.Account

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(blueprint pick)a})

  @impl true
  def mount(_params, _session, socket) do
    workspaces = Map.get(socket.assigns, :workspaces)
    workspace = Map.get(socket.assigns, :workspace)

    blueprints =
      if workspace do
        Account.load_blueprints(workspace).blueprints
      else
        []
      end

    {:ok, assign(socket, workspaces: workspaces, blueprints: blueprints)}
  end
end
