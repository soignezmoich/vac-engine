defmodule VacEngine.MixProject do
  use Mix.Project

  def project do
    [
      app: :vac_engine,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
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
      {:phoenix_live_dashboard, "~> 0.5.1"},
      {:phoenix_live_view, "~> 0.16.3"},
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
    ]
  end

  # Project uses Makefile, type make for info
  defp aliases do
    []
  end
end
