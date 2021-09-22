defmodule VacEngineWeb.UserLive.New do
  use Phoenix.LiveView,
    container: {:div, class: "flex flex-col max-w-full min-w-full"}

  import VacEngineWeb.PermissionHelpers, only: [can?: 3, can!: 3]
  alias VacEngineWeb.UserView
  alias VacEngine.Auth.User
  alias VacEngine.Users
  alias VacEngineWeb.Router.Helpers, as: Routes
  alias VacEngineWeb.UserLive

  on_mount(VacEngineWeb.LivePermissions)

  @impl true
  def render(assigns), do: UserView.render("new.html", assigns)

  @impl true
  def mount(_params, session, socket) do
    can!(socket, :users, :write)

    changeset =
      %User{}
      |> Users.change()
      |> Map.put(:action, :insert)

    {:ok, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"user" => params},
        socket
      ) do
    changeset =
      %User{}
      |> Users.change(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event(
        "create",
        %{"user" => params},
        socket
      ) do
    params = Map.put(params, "password", VacEngine.Token.generate(16))

    can!(socket, :users, :write)

    Users.create(params)
    |> case do
      {:ok, result} ->
        {:noreply,
         socket
         |> push_redirect(to: Routes.live_path(socket, UserLive.Index))}

      {:error, :user, changeset, _changes} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
