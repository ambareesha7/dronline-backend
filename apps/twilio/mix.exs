defmodule Twilio.MixProject do
  use Mix.Project

  def project do
    [
      app: :twilio,
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
      mod: {Twilio.Application, []}
    ]
  end

  defp deps do
    [
      {:joken, "~> 2.4.0"},
      {:tesla, "~> 1.7"},

      # umbrella
      {:authentication, in_umbrella: true}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "support"]
  defp elixirc_paths(_), do: ["lib"]
end
