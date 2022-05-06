defmodule VacEngineWeb.WorkspaceLive.Edit do
  @moduledoc false

  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers

  alias VacEngine.Account

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin workspace)a})

  @impl true
  def mount(%{"workspace_id" => wid}, _session, socket) do
    can!(socket, :manage, :workspaces)

    workspace =
      Account.get_workspace!(wid, fn query ->
        query
        |> Account.load_workspace_stats()
      end)

    changeset =
      workspace
      |> Account.change_workspace()
      |> Map.put(:action, :update)

    socket
    |> assign(edit_workspace: workspace, changeset: changeset)
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
        %{assigns: %{edit_workspace: workspace}} = socket
      ) do
    changeset =
      workspace
      |> Account.change_workspace(params)
      |> Map.put(:action, :update)

    socket
    |> assign(changeset: changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "update",
        %{"workspace" => params},
        %{assigns: %{edit_workspace: workspace}} = socket
      ) do
    can!(socket, :manage, :workspaces)

    Account.update_workspace(workspace, params)
    |> case do
      {:ok, workspace} ->
        socket
        |> push_redirect(to: Routes.workspace_path(socket, :edit, workspace))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event(
        "delete",
        _,
        %{assigns: %{edit_workspace: workspace}} = socket
      ) do
    can!(socket, :delete, workspace)

    Account.delete_workspace(workspace)
    |> case do
      {:ok, _workspace} ->
        socket
        |> push_redirect(
          to: Routes.workspace_path(socket, :index),
          replace: true
        )
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(changeset: changeset)
        |> noreply()
    end
  end
end
