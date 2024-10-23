defmodule Admin.MixProject do
  use Mix.Project

  def project do
    [
      app: :admin,
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
      version: "0.1.0"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:mockery, "~> 2.3"},
      {:sentry, "~> 8.0"},
      {:money, "~> 1.12"},
      {:mailers, in_umbrella: true},
      {:postgres, in_umbrella: true},
      {:proto, in_umbrella: true}
    ]
  end
end
