import Config

require Logger

# Runtime configuration
Logger.info("Running runtime configuration")

case Config.config_env() do
  :prod ->
    database_url = System.fetch_env!("DATABASE_URL")

    config :vac_engine, VacEngine.Repo,
      url: database_url,
      pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))

    secret_key_base = System.fetch_env!("SECRET_KEY_BASE")

    host = System.fetch_env!("HOST")

    port =
      System.fetch_env!("PORT")
      |> String.to_integer()

    {:ok, address} =
      :inet.parse_address(
        System.get_env(
          "ADDRESS",
          "::0"
        )
        |> to_charlist
      )

    config :vac_engine, VacEngineWeb.Endpoint,
      url: [host: host, port: 443, scheme: "https"],
      http: [ip: address, port: port],
      secret_key_base: secret_key_base

    config :vac_engine, VacEngineWeb.Endpoint, server: true

  :dev ->
    config :vac_engine, VacEngine.Repo,
      url: System.get_env("DATABASE_URL", "postgres://localhost/vac_engine")

  :test ->
    config :vac_engine, VacEngine.Repo,
      url:
        System.get_env("DATABASE_URL", "postgres://localhost/vac_engine_test")
end
