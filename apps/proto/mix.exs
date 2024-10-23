defmodule Proto.MixProject do
  use Mix.Project

  def project do
    [
      app: :proto,
      build_path: "../../_build",
      compilers: Mix.compilers(),
      config_path: "../../config/config.exs",
      deps: deps(),
      deps_path: "../../deps",
      elixir: "~> 1.8",
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
      mod: {Proto.Application, []}
    ]
  end

  defp deps do
    [
      {:geo_postgis, "~> 3.5"},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_view, "~> 2.0"},
      {:protobuf, "~> 0.7.1"},
      {:timex, "~> 3.7"}
    ]
  end
end
