defmodule Postgres.Mixfile do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :postgres,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps: deps(),
      deps_path: "../../deps",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      test_paths: ["lib"],
      test_pattern: "*.test.exs",
      version: "0.0.1"
    ]
  end

  def application do
    [
      mod: {Postgres.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ecto_sql, "~> 3.10"},
      {:elixir_uuid, "~> 1.0"},
      {:pbkdf2_elixir, "~> 2.1"},
      {:postgrex, "~> 0.17.1"},
      {:jason, "~> 1.4"},
      {:timex, "~> 3.7"},
      {:csv, "~> 3.2.1"},
      {:geo_postgis, "~> 3.5"},
      {:oban, "~> 2.10.1"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
