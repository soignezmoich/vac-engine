defmodule VacEngineWeb.WorkspaceLive.New do
  @moduledoc false

  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers

  alias VacEngine.Account
  alias VacEngine.Account.Workspace

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin workspace)a})

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :manage, :workspaces)

    changeset =
      %Workspace{}
      |> Account.change_workspace()
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
        %{"workspace" => params},
        socket
      ) do
    changeset =
      %Workspace{}
      |> Account.change_workspace(params)
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "create",
        %{"workspace" => params},
        socket
      ) do
    can!(socket, :manage, :workspaces)

    Account.create_workspace(params)
    |> case do
      {:ok, result} ->
        socket
        |> push_redirect(to: Routes.workspace_path(socket, :edit, result))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(changeset: changeset)
        |> noreply()
    end
  end
end
