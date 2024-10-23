defmodule Firebase.MixProject do
  use Mix.Project

  def project do
    [
      app: :firebase,
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
      extra_applications: [:logger],
      mod: {Firebase.Application, []}
    ]
  end

  defp deps do
    [
      {:encode_anything, git: "https://git.appunite.com/tobiasz/encode_anything"},
      {:joken, "~> 2.4.0"},
      {:joken_jwks, "~> 1.6.0"},
      {:mockery, "~> 2.3"},
      {:sentry, "~> 8.0"},
      {:tesla, "~> 1.7"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "support"]
  defp elixirc_paths(_), do: ["lib"]
end
