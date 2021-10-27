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

    ssl_key = System.get_env("SSL_KEY_PATH")
    ssl_cert = System.get_env("SSL_CERT_PATH")

    config :vac_engine, VacEngineWeb.Endpoint,
      url: [host: host, port: 443, scheme: "https"],
      secret_key_base: secret_key_base

    if ssl_key && ssl_cert do
      config :vac_engine, VacEngineWeb.Endpoint,
        https: [
          :inet6,
          ip: address,
          port: port,
          cipher_suite: :strong,
          keyfile: ssl_key,
          certfile: ssl_cert,
          transport_options: [num_acceptors: 1000, max_connections: 10_000]
        ]
    else
      config :vac_engine, VacEngineWeb.Endpoint,
        http: [
          ip: address,
          port: port,
          transport_options: [num_acceptors: 1000, max_connections: 10_000]
        ]
    end

    config :vac_engine, VacEngineWeb.Endpoint, server: true

  :dev ->
    config :vac_engine, VacEngine.Repo,
      url: System.get_env("DATABASE_URL", "postgres://localhost/vac_engine")

  :test ->
    config :vac_engine, VacEngine.Repo,
      url:
        System.get_env("DATABASE_URL", "postgres://localhost/vac_engine_test")
end
