defmodule VacEngineWeb.ApiKeyLive.Index do
  @moduledoc """
  Index of all API keys.
  """

  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers

  alias VacEngine.Account

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin api_key)a})

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :manage, :api_keys)

    socket
    |> assign(tokens: Account.list_api_tokens())
    |> ok()
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end
end
