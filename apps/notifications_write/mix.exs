defmodule NotificationsWrite.MixProject do
  use Mix.Project

  def project do
    [
      app: :notifications_write,
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
      {:postgres, in_umbrella: true},
      {:push_notifications, in_umbrella: true}
    ]
  end
end
