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
    plug(:no_cache)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:require_api_key)
  end

  scope "/", VacEngineWeb do
    pipe_through([:browser, :require_role, :fetch_workspaces])

    get("/", WelcomeController, :index)
    live("/nav", NavLive.Index, :index, as: :nav)

    live("/users", UserLive.Index, :index, as: :user)
    live("/users/new", UserLive.New, :new, as: :user)
    live("/users/:user_id", UserLive.Edit, :edit, as: :user)

    live("/api-keys", ApiKeyLive.Index, :index, as: :api_key)
    live("/api-keys/new", ApiKeyLive.New, :new, as: :api_key)
    live("/api-keys/:role_id", ApiKeyLive.Edit, :edit, as: :api_key)

    live("/workspaces", WorkspaceLive.Index, :index, as: :workspace)
    live("/workspaces/new", WorkspaceLive.New, :new, as: :workspace)

    live("/workspaces/:workspace_id", WorkspaceLive.Edit, :edit, as: :workspace)
    live("/blueprints/pick", BlueprintLive.Pick, :pick, as: :blueprint)

    scope "/w/:workspace_id", Workspace, as: :workspace do
      pipe_through([:fetch_current_workspace])

      live("/", DashboardLive.Index, :index, as: :dashboard)
      live("/blueprints", BlueprintLive.Index, :index, as: :blueprint)

      live("/blueprints/pick", BlueprintLive.Pick, :pick, as: :blueprint)
      live("/blueprints/new", BlueprintLive.New, :new, as: :blueprint)

      live("/blueprints/:blueprint_id", BlueprintLive.Edit, :summary,
        as: :blueprint
      )

      live(
        "/blueprints/:blueprint_id/variables",
        BlueprintLive.Edit,
        :variables,
        as: :blueprint
      )

      live(
        "/blueprints/:blueprint_id/deductions",
        BlueprintLive.Edit,
        :deductions,
        as: :blueprint
      )

      live(
        "/blueprints/:blueprint_id/import",
        BlueprintLive.Edit,
        :import,
        as: :blueprint
      )

      live("/portals", PortalLive.Index, :index, as: :portal)
      live("/portals/:portal_id", PortalLive.Edit, :edit, as: :portal)
    end
  end

  scope "/", VacEngineWeb do
    pipe_through([:browser, :require_no_role])
    live("/login", AuthLive.Login, :form, as: :login)
    get("/login/:token", AuthController, :login, as: :login)
  end

  scope "/", VacEngineWeb do
    pipe_through([:browser])
    match(:*, "/logout", AuthController, :logout, as: :logout)
  end

  scope "/api", VacEngineWeb.Api, as: :api do
    pipe_through([:api])
    post("/p/:portal_id/run", PubController, :run, as: :pub)
    get("/p/:portal_id/info", PubController, :info, as: :pub)
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: VacEngineWeb.Telemetry)
    end
  end
end
