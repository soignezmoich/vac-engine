defmodule VacEngineWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :vac_engine

  @session_options [
    store: :cookie,
    key:
      Application.get_env(:vac_engine, VacEngineWeb.Endpoint)
      |> Keyword.fetch!(:session_key),
    signing_salt:
      Application.get_env(:vac_engine, VacEngineWeb.Endpoint)
      |> Keyword.fetch!(:session_signing_salt),
    encryption_salt:
      Application.get_env(:vac_engine, VacEngineWeb.Endpoint)
      |> Keyword.fetch!(:session_encryption_salt),
    max_age: 365 * 3600 * 24,
    same_site: "Strict"
  ]

  # socket("/socket", VacEngineWeb.UserSocket,
  #  websocket: true,
  #  longpoll: false
  # )

  socket("/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]
  )

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :vac_engine,
    gzip: false,
    only:
      ~w(css fonts icons images js favicon.ico favicon.svg favicon.png robots.txt)
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :vac_engine)
  end

  plug(Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(VacEngineWeb.Router)

  alias VacEngine.Account.Role
  alias VacEngine.Account.User
  alias VacEngine.Account.Session

  def disconnect_live_views(%Role{} = role) do
    disconnect_live_views(role.id)
  end

  def disconnect_live_views(%User{} = user) do
    disconnect_live_views(user.role_id)
  end

  def disconnect_live_views(%Session{} = s) do
    disconnect_live_views(s.role_id)
  end

  def disconnect_live_views(role_id) when is_number(role_id) do
    broadcast(
      "roles_socket:#{role_id}",
      "disconnect",
      %{}
    )
  end
end
