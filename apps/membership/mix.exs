defmodule Membership.MixProject do
  use Mix.Project

  def project do
    [
      app: :membership,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps: deps(),
      deps_path: "../../deps",
      elixir: "~> 1.7",
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
      mod: {Membership.Application, []}
    ]
  end

  defp deps do
    [
      {:elixir_xml_to_map, "~> 0.1.2"},
      {:mockery, "~> 2.3"},
      {:postgres, in_umbrella: true},
      {:proto, in_umbrella: true},
      {:specialist_profile, in_umbrella: true},
      {:tesla, "~> 1.7"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "support"]
  defp elixirc_paths(_), do: ["lib"]
end
