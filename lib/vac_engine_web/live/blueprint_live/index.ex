defmodule VacEngineWeb.BlueprintLive.Index do
  use VacEngineWeb, :live_view

  import VacEngineWeb.PermissionHelpers, only: [can!: 3]
  alias VacEngine.Processor
  alias VacEngine.Accounts

  on_mount(VacEngineWeb.LivePermissions)

  @impl true
  def mount(%{"workspace_id" => workspace_id}, _session, socket) do
    # TODO Change permissions to workspace specific
    can!(socket, :workspaces, :write)
    workspace = Accounts.get_workspace!(workspace_id)

    blueprints = Processor.list_blueprints(workspace)
    {:ok, assign(socket, blueprints: blueprints)}
  end
end
