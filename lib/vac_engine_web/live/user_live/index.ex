defmodule VacEngineWeb.UserLive.Index do
  use Phoenix.LiveView,
    container: {:div, class: "flex flex-col max-w-full min-w-full"}

  import VacEngineWeb.PermissionHelpers, only: [can!: 3]
  alias VacEngineWeb.UserView
  alias VacEngine.Accounts

  on_mount(VacEngineWeb.LivePermissions)

  @impl true
  def render(assigns), do: UserView.render("index.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :users, :read)

    {:ok,
     assign(socket,
       users: Accounts.list_users()
     )}
  end
end
