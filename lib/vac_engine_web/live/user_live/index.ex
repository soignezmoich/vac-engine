defmodule VacEngineWeb.UserLive.Index do
  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers

  alias VacEngine.Account

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin user)a})

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :manage, :users)

    socket
    |> assign(users: Account.list_users(&Account.load_user_activity/1))
    |> ok()
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end
end
