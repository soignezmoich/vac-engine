use Mix.Config

#
# DATABASE_TEST_URL must be defined when the app is compiled for testing
config :vac_engine, VacEngine.Repo,
  url: System.fetch_env!("DATABASE_TEST_URL"),
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :vac_engine, VacEngineWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
