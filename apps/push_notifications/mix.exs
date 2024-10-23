defmodule PushNotifications.MixProject do
  use Mix.Project

  def project do
    [
      app: :push_notifications,
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
      mod: {PushNotifications.Application, []}
    ]
  end

  defp deps do
    [
      {:castore, "~> 0.1.0"},
      {:encode_anything, git: "https://git.appunite.com/tobiasz/encode_anything"},
      {:joken, "~> 2.4.0"},
      {:mint, "~> 1.5"},
      {:mockery, "~> 2.3"},
      {:sentry, "~> 8.0"},
      {:tesla, "~> 1.7"},

      # umbrella
      {:postgres, in_umbrella: true}

      # README
      # think 10 times before you add another umbrella app as dependency here
      # it will mean that this app won't be able to send any notifications
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "support"]
  defp elixirc_paths(_), do: ["lib"]
end
