defmodule VacEngineWeb.WorkspaceLive.Index do
  use VacEngineWeb, :live_view

  import VacEngineWeb.PermissionHelpers, only: [can!: 3]
  alias VacEngine.Account

  on_mount(VacEngineWeb.LivePermissions)

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :workspaces, :read)

    {:ok,
     assign(socket,
       workspaces: Account.list_workspaces()
     )}
  end
end
