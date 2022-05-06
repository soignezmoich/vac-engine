defmodule VacEngineWeb.UserLive.New do
  @moduledoc false

  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers
  import VacEngineWeb.PermissionHelpers

  alias VacEngine.Account.User
  alias VacEngine.Account
  alias VacEngineWeb.Router.Helpers, as: Routes

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin user)a})

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :manage, :users)

    changeset =
      %User{}
      |> Account.change_user()
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset)
    |> ok()
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
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

    socket
    |> assign(changeset: changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "create",
        %{"user" => params},
        socket
      ) do
    can!(socket, :manage, :users)
    params = Map.put(params, "password", Account.generate_secret(16))

    Account.create_user(params)
    |> case do
      {:ok, user} ->
        socket
        |> push_redirect(to: Routes.user_path(socket, :edit, user))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(changeset: changeset)
        |> noreply()
    end
  end
end
