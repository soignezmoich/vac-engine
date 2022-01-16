import Config

# Those values are compile time
# All environment variables used in this file will be compiled into the
# application and cannot be set at runtime
config :vac_engine, VacEngineWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  session_signing_salt: System.fetch_env!("SESSION_SIGNING_SALT"),
  session_encryption_salt: System.fetch_env!("SESSION_ENCRYPTION_SALT"),
  session_key: System.fetch_env!("SESSION_KEY"),
  live_view: [
    signing_salt: System.fetch_env!("LIVE_VIEW_SALT")
  ]

# Do not print debug messages in production
config :logger, level: :info

# To display a loading spinner for a minimal time, and also protect from DoS
# Session timeout at 1 hour
config :vac_engine, login_delay: 2000, session_timeout: 3600

case System.get_env("FORCE_SSL") do
  "FORWARDED" ->
    config :vac_engine, VacEngineWeb.Endpoint,
      force_ssl: [hsts: true, rewrite_on: [:x_forwarded_proto]]

  "FORCE" ->
    config :vac_engine, VacEngineWeb.Endpoint, force_ssl: [hsts: true]

  _ ->
    nil
end

remote_ip_header =
  System.get_env("REMOTE_IP_HEADER", nil)
  |> case do
    nil -> nil
    s -> String.downcase(s)
  end

config :vac_engine, remote_ip_header: remote_ip_header
