defmodule VacEngineWeb.UserLive.Index do
  use VacEngineWeb, :live_view

  alias VacEngineWeb.UserLive
  alias VacEngine.Account

  on_mount(VacEngineWeb.LiveRole)

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :users, :read)

    {:ok,
     assign(socket,
       users: Account.list_users()
     )}
  end
end
