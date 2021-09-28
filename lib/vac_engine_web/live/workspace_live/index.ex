defmodule VacEngineWeb.WorkspaceLive.Index do
  use Phoenix.LiveView,
    container: {:div, class: "flex flex-col max-w-full min-w-full"}

  import VacEngineWeb.PermissionHelpers, only: [can!: 3]
  alias VacEngineWeb.WorkspaceView
  alias VacEngine.Accounts

  on_mount(VacEngineWeb.LivePermissions)

  @impl true
  def render(assigns), do: WorkspaceView.render("index.html", assigns)

  @impl true
  def mount(_params, session, socket) do
    can!(socket, :workspaces, :read)

    {:ok,
     assign(socket,
       users: Accounts.list_workspaces()
     )}
  end
end
