defmodule VacEngineWeb.WorkspaceLive.Index do
  use VacEngineWeb, :live_view

  alias VacEngine.Account

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin workspace)a})

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :manage, :workspaces)

    {:ok,
     assign(socket,
       workspaces: Account.list_workspaces()
     )}
  end
end
