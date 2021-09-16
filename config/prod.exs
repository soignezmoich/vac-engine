use Mix.Config

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
config :vac_engine, login_delay: 4000
