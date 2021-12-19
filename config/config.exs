# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :vac_engine,
  ecto_repos: [VacEngine.Repo]

# Configures the endpoint
config :vac_engine, VacEngineWeb.Endpoint,
  url: [host: "localhost"],
  live_view: [
    signing_salt: "rn7sBRyD84HI0vPGUgv1YoO7FGRAgT5z6YfVMxaK"
  ],
  secret_key_base:
    "CJrwieShyn60rAAligMhqc6bOHs6QZq7why2weSMrf8OjETOtVHbchxHHeS3W6leek0LsBD4gIgSl6z9",
  render_errors: [
    view: VacEngineWeb.ErrorView,
    accepts: ~w(html json),
    layout: false
  ],
  pubsub_server: VacEngine.PubSub,
  session_signing_salt: "s829bssj(92jldk",
  session_encryption_salt: "SMXCY=NGOIjs",
  session_key: "_vac_engine_session_key"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:remote_ip, :request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Default Locale
config :gettext, :default_locale, "en"
config :vac_engine, VacEngine.Gettext, default_locale: "en"

config :vac_engine, cache_check_interval: 5000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
