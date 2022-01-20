import Config

config :vac_engine, VacEngine.Repo, pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :vac_engine, VacEngineWeb.Endpoint,
  http: [port: 4002],
  server: false

config :vac_engine, cache_check_interval: 600_000, session_timeout: false

# Print only warnings and errors during test
config :logger, level: :warn
