defmodule VacEngineWeb.WorkspaceLive.Index do
  use VacEngineWeb, :live_view

  alias VacEngine.Account
  alias VacEngine.Query

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin workspace)a})

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :manage, :workspaces)

    {:ok,
     assign(socket,
       workspaces:
         Account.list_workspaces(fn query ->
           query
           |> Account.load_workspace_stats()
           |> Query.order_by(:name)
         end)
     )}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end
end
