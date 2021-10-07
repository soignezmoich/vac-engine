defmodule VacEngineWeb.Router do
  use VacEngineWeb, :router

  pipeline :browser do
    plug(RemoteIp)
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_role_session)
    plug(:put_root_layout, {VacEngineWeb.LayoutView, :root})
    plug(:put_layout, false)
    plug(:no_cache)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:require_api_key)
  end

  scope "/", VacEngineWeb do
    pipe_through([:browser, :require_role])

    get("/", DashboardController, :index)

    live("/users", UserLive.Index)
    live("/users/new", UserLive.New)
    live("/users/:user_id", UserLive.Edit)

    live("/workspaces", WorkspaceLive.Index)
    live("/workspaces/:workspace_id/blueprints", BlueprintLive.Index)

    live(
      "/blueprints/:blueprint_id",
      BlueprintLive.Edit
    )
  end

  scope "/", VacEngineWeb do
    pipe_through([:browser, :require_no_role])
    live("/login", AuthLive.Login, :login)
    get("/login/:token", AuthController, :login)
  end

  scope "/", VacEngineWeb do
    pipe_through([:browser])
    match(:*, "/logout", AuthController, :logout)
  end

  scope "/api", VacEngineWeb.Api do
    pipe_through([:api])
    post("/p/:portal_id/run", PubController, :run)
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: VacEngineWeb.Telemetry)
    end
  end
end
