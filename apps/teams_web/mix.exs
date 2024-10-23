defmodule TeamsWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :teams_web,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {TeamsWeb.Application, []},
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
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_pubsub, "~> 2.1.3"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_view, "~> 0.20.0"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.6.1"},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:authentication, in_umbrella: true},
      {:specialist_profile, in_umbrella: true},
      {:teams, in_umbrella: true},
      {:proto, in_umbrella: true}
    ]
  end

  defp aliases do
    [
      setup: ["assets.setup", "assets.build"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind teams_web", "esbuild teams_web"],
      "assets.deploy": ["tailwind teams_web --minify", "esbuild teams_web --minify", "phx.digest"]
    ]
  end
end
