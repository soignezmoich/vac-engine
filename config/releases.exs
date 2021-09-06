import Config

database_url = System.fetch_env!("DATABASE_URL")

config :vac_engine, VacEngine.Repo,
  url: database_url,
  pool_size: String.to_integer(System.fetch_env!("POOL_SIZE"))

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
live_view_salt = System.fetch_env!("LIVE_VIEW_SALT")

host = System.fetch_env!("HOST")

port =
  System.fetch_env!("PORT")
  |> String.to_integer()

config :vac_engine, VacEngineWeb.Endpoint,
  url: [host: host, port: 443, scheme: "https"],
  http: [ip: {127, 0, 0, 1}, port: port],
  secret_key_base: secret_key_base,
  live_view: [
    signing_salt: live_view_salt,
  ],

config :vac_engine, VacEngineWeb.Endpoint, server: true
