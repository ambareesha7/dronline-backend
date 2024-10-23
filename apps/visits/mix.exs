defmodule Visits.MixProject do
  use Mix.Project

  def project do
    [
      app: :visits,
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
      mod: {Visits.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:quantum, "~> 3.0-rc"},
      {:money, "~> 1.12"},
      {:emr, in_umbrella: true},
      {:specialist_profile, in_umbrella: true},
      {:patient_profile, in_umbrella: true},
      {:patient_profiles_management, in_umbrella: true},
      {:payments_api, in_umbrella: true},
      {:postgres, in_umbrella: true},
      {:push_notifications, in_umbrella: true},
      {:specialist_profile, in_umbrella: true},
      {:teams, in_umbrella: true},
      {:urgent_care, in_umbrella: true}
    ]
  end
end
