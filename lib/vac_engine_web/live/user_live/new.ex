defmodule VacEngineWeb.UserLive.New do
  use Phoenix.LiveView,
    container: {:div, class: "flex flex-col max-w-full min-w-full"}

  import VacEngineWeb.PermissionHelpers
  alias VacEngineWeb.UserView
  alias VacEngine.Accounts.User
  alias VacEngine.Accounts
  alias VacEngineWeb.Router.Helpers, as: Routes
  alias VacEngineWeb.UserLive

  on_mount(VacEngineWeb.LivePermissions)

  @impl true
  def render(assigns), do: UserView.render("new.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :users, :write)

    changeset =
      %User{}
      |> Accounts.change_user()
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
      |> Accounts.change_user(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event(
        "create",
        %{"user" => params},
        socket
      ) do
    params = Map.put(params, "password", Accounts.generate_token(16))

    can!(socket, :users, :write)

    Accounts.create_user(params)
    |> case do
      {:ok, _result} ->
        {:noreply,
         socket
         |> push_redirect(to: Routes.live_path(socket, UserLive.Index))}

      {:error, :user, changeset, _changes} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
