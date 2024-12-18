defmodule Typer.MixProject do
  use Mix.Project

  def project do
    [
      app: :typer,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      mod: {Typer.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Auth
      {:acts, in_umbrella: true},  # Add centralized auth

      {:pbkdf2_elixir, "~> 2.0"},
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.6.2"},
      {:ecto_sql, "~> 3.12.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},  # Updating to latest version
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_live_view, "~> 0.20.17"},
      {:floki, "~> 0.36.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.5"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.4", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.17.1"},
      {:finch, "~> 0.19.0"},
      {:telemetry_metrics, "~> 1.0"},  # Updating to latest version
      {:telemetry_poller, "~> 1.1.0"},
      {:gettext, "~> 0.26.1"},
      {:jason, "~> 1.4.4"},
      {:dns_cluster, "~> 0.1.3"},
      {:plug_cowboy, "~> 2.7.2"},
      {:file_system, "~> 1.0"},

      # Blog functionality
      {:makeup_elixir, ">= 0.0.0"},
      {:earmark, "~> 1.4"},
      {:makeup_erlang, ">= 0.0.0"},

      # Cache
      {:con_cache, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],

      # Add a new alias for blog post processing
      "blog.process": ["run priv/posts/process_posts.exs"]
    ]
  end
end
