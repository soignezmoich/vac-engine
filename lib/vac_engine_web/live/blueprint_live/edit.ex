defmodule VacEngineWeb.BlueprintLive.Edit do
  use VacEngineWeb, :live_view

  import VacEngineWeb.PermissionHelpers, only: [can!: 3]
  alias VacEngine.Blueprints

  on_mount(VacEngineWeb.LivePermissions)

  @impl true
  def mount(%{"blueprint_id" => blueprint_id}, _session, socket) do
    # TODO real permission check here
    can!(socket, :workspaces, :write)
    blueprint = Blueprints.get_blueprint!(blueprint_id)

    {:ok, assign(socket, blueprint: blueprint)}
  end
end
