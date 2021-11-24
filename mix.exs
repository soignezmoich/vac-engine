defmodule VacEngine.MixProject do
  use Mix.Project

  @source_url "https://github.com/soignezmoich/vac-engine"
  # also change in api.yaml
  @version "1.0.3"

  @external_resource "#{__DIR__}/.coverignore"
  @ignore_modules File.stream!("#{__DIR__}/.coverignore")
                  |> Enum.map(fn s ->
                    String.to_atom("Elixir.#{String.trim(s)}")
                  end)

  def project do
    [
      app: :vac_engine,
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [
        ignore_modules: @ignore_modules
      ],
      name: "Vac Engine",
      description: "A decision engine based on logic blueprints",
      package: package(),
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {VacEngine.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "test/fixtures"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      output: "docs/",
      extras: [
        "README.md",
        "INSTALLATION.md",
        "DEPLOYMENT.md",
        "DEVELOPMENT.md"
      ],
      extra_section: "GUIDES",
      groups_for_extras: [
        "Getting started": ~r/.*README.md/,
        "How-To's": ~r/.*/
      ],
      groups_for_modules: [
        "API entry points": [
          VacEngine,
          VacEngine.Account,
          VacEngine.Processor,
          VacEngine.Pub
        ],
        Processor: [
          VacEngine.Processor.Ast,
          VacEngine.Processor.Compiler,
          VacEngine.Processor.Convert,
          VacEngine.Processor.Info,
          VacEngine.Processor.Library,
          VacEngine.Processor.Library.Functions,
          VacEngine.Processor.Meta,
          VacEngine.Processor.State,
          VacEngine.Processor.State.Env,
          VacEngine.Processor.State.Input,
          VacEngine.Processor.State.List
        ],
        Publication: [
          VacEngine.Pub.Portal,
          VacEngine.Pub.Publication
        ],
        Utilities: [
          VacEngine.EctoHelpers,
          VacEngine.EnumHelpers,
          VacEngine.Hash,
          VacEngine.Release,
          VacEngine.PipeHelpers
        ],
        Web: [
          VacEngineWeb,
          VacEngineWeb.Api.ErrorView,
          VacEngineWeb.Api.FallbackController,
          VacEngineWeb.Api.PubController,
          VacEngineWeb.Api.PubView,
          VacEngineWeb.ApiKeyLive.Edit,
          VacEngineWeb.ApiKeyLive.Index,
          VacEngineWeb.ApiKeyLive.New,
          VacEngineWeb.AuthController,
          VacEngineWeb.AuthLive.Login,
          VacEngineWeb.AuthLive.Login.LoginForm,
          VacEngineWeb.AuthLive.LoginFormComponent,
          VacEngineWeb.AuthView,
          VacEngineWeb.ButtonComponent,
          VacEngineWeb.ConnHelpers,
          VacEngineWeb.Editor.BranchComponent,
          VacEngineWeb.Editor.CellComponent,
          VacEngineWeb.Editor.DeductionComponent,
          VacEngineWeb.Editor.DeductionHeaderComponent,
          VacEngineWeb.Editor.DeductionListComponent,
          VacEngineWeb.Editor.DeductionSetEditorComponent,
          VacEngineWeb.Editor.VariableComponent,
          VacEngineWeb.Editor.VariableListComponent,
          VacEngineWeb.Editor.VariableSetEditorComponent,
          VacEngineWeb.Endpoint,
          VacEngineWeb.ErrorHelpers,
          VacEngineWeb.ErrorView,
          VacEngineWeb.FallbackController,
          VacEngineWeb.FlashComponent,
          VacEngineWeb.FlexCenterComponent,
          VacEngineWeb.FormHelpers,
          VacEngineWeb.FormatHelpers,
          VacEngineWeb.Gettext,
          VacEngineWeb.HeaderComponent,
          VacEngineWeb.IconComponent,
          VacEngineWeb.KlassHelpers,
          VacEngineWeb.LayoutView,
          VacEngineWeb.LiveLocation,
          VacEngineWeb.LiveRole,
          VacEngineWeb.LiveWorkspace,
          VacEngineWeb.LoaderCardComponent,
          VacEngineWeb.NavLive.Index,
          VacEngineWeb.PathHelpers,
          VacEngineWeb.PermissionHelpers,
          VacEngineWeb.Router,
          VacEngineWeb.Router.Helpers,
          VacEngineWeb.Telemetry,
          VacEngineWeb.TextCardComponent,
          VacEngineWeb.ToggleComponent,
          VacEngineWeb.UserLive.Edit,
          VacEngineWeb.UserLive.Index,
          VacEngineWeb.UserLive.New,
          VacEngineWeb.UserSocket,
          VacEngineWeb.VersionHelpers,
          VacEngineWeb.WelcomeController,
          VacEngineWeb.WelcomeView,
          VacEngineWeb.Workspace.BlueprintLive.Edit,
          VacEngineWeb.Workspace.BlueprintLive.ImportComponent,
          VacEngineWeb.Workspace.BlueprintLive.Index,
          VacEngineWeb.Workspace.BlueprintLive.New,
          VacEngineWeb.Workspace.BlueprintLive.Pick,
          VacEngineWeb.Workspace.BlueprintLive.SummaryComponent,
          VacEngineWeb.Workspace.DashboardLive.Index,
          VacEngineWeb.Workspace.PortalLive.Edit,
          VacEngineWeb.Workspace.PortalLive.Index,
          VacEngineWeb.Workspace.PortalLive.New,
          VacEngineWeb.WorkspaceLive.Edit,
          VacEngineWeb.WorkspaceLive.Index,
          VacEngineWeb.WorkspaceLive.New
        ],
        "Web Plugs": [
          VacEngineWeb.ApiPlug,
          VacEngineWeb.CachePlug,
          VacEngineWeb.RolePlug,
          VacEngineWeb.WorkspacePlug
        ]
      ]
    ]
  end

  defp package do
    [
      licenses: ["AGPL v3"],
      links: %{"GitHub" => @source_url}
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Phoenix
      {:phoenix, "~> 1.6.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0.4"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.6.0"},
      {:phoenix_live_view, "~> 0.17.1"},
      {:telemetry_metrics, "~> 0.6.1"},
      {:telemetry_poller, "~> 0.4"},

      # DB Connection
      {:ecto_sql, "~> 3.7"},
      {:postgrex, ">= 0.0.0"},

      # Localization
      {:gettext, "~> 0.11"},

      # JSON library
      {:jason, "~> 1.0"},

      # HTTP Server
      {:plug_cowboy, "~> 2.0"},

      # Color conversion
      {:hsluv, "~> 0.2"},

      # Use base24 for ids
      {:base24, "~> 0.1.1"},

      # Plug that extract remote ip from different sources
      {:remote_ip, "~> 1.0"},

      # Strong password hashing
      {:argon2_elixir, "~> 2.0"},

      # Ecto postgresql inet data type support
      {:ecto_network, "~> 1.3.0"},

      # Date and time manipulation library
      {:timex, "~> 3.0"},

      # Static analysis
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},

      # EX Docs generation
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},

      # TOTP
      {:nimble_totp, "~> 0.1.0"},

      # Generate QR code
      {:eqrcode, "~> 0.1.10"}
    ]
  end

  # Project uses Makefile, type make for info
  defp aliases do
    []
  end
end
