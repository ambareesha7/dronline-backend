defmodule NotificationsRead.MixProject do
  use Mix.Project

  def project do
    [
      app: :notifications_read,
      build_path: "../../_build",
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
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:emr, in_umbrella: true},
      {:notifications_write, in_umbrella: true}
    ]
  end
end
