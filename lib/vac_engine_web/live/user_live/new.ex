defmodule VacEngineWeb.UserLive.New do
  use VacEngineWeb, :live_view

  import VacEngineWeb.PermissionHelpers
  alias VacEngine.Account.User
  alias VacEngine.Account
  alias VacEngineWeb.Router.Helpers, as: Routes
  alias VacEngineWeb.UserLive

  on_mount(VacEngineWeb.LiveRole)


  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :admin_users)

    changeset =
      %User{}
      |> Account.change_user()
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
      |> Account.change_user(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event(
        "create",
        %{"user" => params},
        socket
      ) do
    params = Map.put(params, "password", Account.generate_secret(16))

    can!(socket, :admin_users)

    Account.create_user(params)
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
