defmodule VacEngineWeb.UserLive.Index do
  use Phoenix.LiveView,
    container: {:div, class: "flex flex-col max-w-full min-w-full"}

  import VacEngineWeb.PermissionHelpers, only: [can!: 3]
  alias VacEngineWeb.UserView
  alias VacEngine.Users

  on_mount(VacEngineWeb.LivePermissions)

  @impl true
  def render(assigns), do: UserView.render("index.html", assigns)

  @impl true
  def mount(_params, session, socket) do
    can!(socket, :users, :read)

    {:ok,
     assign(socket,
       users: Users.list()
     )}
  end

  @impl true
  def handle_event(
        "generate_password",
        %{"id" => user_id},
        socket
      ) do
    can!(socket, :users, :write)

    {:noreply,
     assign(socket,
       users: Users.list()
     )}
  end
end
