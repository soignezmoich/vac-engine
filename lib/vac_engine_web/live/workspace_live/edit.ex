defmodule VacEngineWeb.WorkspaceLive.Edit do
  use VacEngineWeb, :live_view

  alias VacEngine.Account

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin workspace)a})

  @impl true
  def mount(%{"workspace_id" => wid}, _session, socket) do
    can!(socket, :manage, :workspaces)

    {:ok, workspace} = Account.fetch_workspace(wid)

    changeset =
      workspace
      |> Account.change_workspace()
      |> Map.put(:action, :update)

    {:ok, assign(socket, edit_workspace: workspace, changeset: changeset)}
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

    {:noreply, assign(socket, changeset: changeset)}
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
        {:noreply,
         socket
         |> push_redirect(to: Routes.workspace_path(socket, :edit, workspace))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
