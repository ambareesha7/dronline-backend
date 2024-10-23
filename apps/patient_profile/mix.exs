defmodule PatientProfile.MixProject do
  use Mix.Project

  def project do
    [
      app: :patient_profile,
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

  defp deps do
    [
      {:encode_anything, git: "https://git.appunite.com/tobiasz/encode_anything"},
      {:mockery, "~> 2.3"},
      {:sentry, "~> 8.0"},

      # umbrella
      {:postgres, in_umbrella: true},
      {:proto, in_umbrella: true},
      {:insurance, in_umbrella: true}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "support"]
  defp elixirc_paths(_), do: ["lib"]
end
