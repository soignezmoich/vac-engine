defmodule VacEngineWeb.WorkspaceLive.Index do
  @moduledoc false

  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers

  alias VacEngine.Account
  alias VacEngine.Query

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin workspace)a})

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :manage, :workspaces)

    socket
    |> assign(
      workspaces:
        Account.list_workspaces(fn query ->
          query
          |> Account.load_workspace_stats()
          |> Query.order_by(:name)
        end)
    )
    |> ok()
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end
end
