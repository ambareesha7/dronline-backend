defmodule EMR.MixProject do
  use Mix.Project

  def project do
    [
      app: :emr,
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
      mod: {EMR.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ex_aws, "~> 2.4"},
      {:ex_aws_s3, "~> 2.4"},
      # umbrella
      {:channel_broadcast, in_umbrella: true},
      {:firebase, in_umbrella: true},
      {:notifications_write, in_umbrella: true},
      {:patient_profile, in_umbrella: true},
      {:postgres, in_umbrella: true},
      {:teams, in_umbrella: true},
      {:twilio, in_umbrella: true},
      {:insurance, in_umbrella: true},
      {:mailers, in_umbrella: true}
    ]
  end
end
