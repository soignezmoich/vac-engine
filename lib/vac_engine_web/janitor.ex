defmodule VacEngineWeb.Janitor do
  @moduledoc false

  use GenServer
  require Logger
  alias VacEngine.Account
  alias VacEngineWeb.Endpoint

  @timeout Application.compile_env!(:vac_engine, :session_timeout)

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    Logger.metadata(context: "janitor")
    Logger.info("Starting Janitor")

    if @timeout && @timeout > 0 do
      send(self(), :check_sessions)
    end

    {:ok, %{}}
  end

  @impl true
  def handle_info(:check_sessions, state) do
    Logger.info("Cleaning inactive sessions")

    Account.list_sessions(fn q ->
      q
      |> Account.filter_inactive_sessions(3600)
    end)
    |> Enum.each(fn s ->
      Account.revoke_session(s)
      Endpoint.disconnect_live_views(s)
    end)

    Process.send_after(self(), :check_sessions, 60_000)
    {:noreply, state}
  end
end
