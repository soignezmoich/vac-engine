defmodule VacEngineWeb.WorkspaceLive.New do
  use VacEngineWeb, :live_view

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

    {:ok, assign(socket, changeset: changeset)}
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

    {:noreply, assign(socket, changeset: changeset)}
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
      {:ok, _result} ->
        {:noreply,
         socket
         |> push_redirect(to: Routes.workspace_path(socket, :index))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
