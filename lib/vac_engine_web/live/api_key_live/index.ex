defmodule VacEngineWeb.ApiKeyLive.Index do
  use VacEngineWeb, :live_view

  alias VacEngine.Account

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin api_key)a})

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :manage, :api_keys)

    {:ok,
     assign(socket,
       tokens: Account.list_api_tokens()
     )}
  end
end
