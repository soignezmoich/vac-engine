defmodule VacEngine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      VacEngine.Repo,
      # Start the Telemetry supervisor
      VacEngineWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: VacEngine.PubSub},
      # Start the Endpoint (http/https)
      VacEngineWeb.Endpoint,
      # Start the cache engine for publisher
      VacEngine.Pub.Cache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VacEngine.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    VacEngineWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
