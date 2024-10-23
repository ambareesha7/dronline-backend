defmodule MembershipMock.MixProject do
  use Mix.Project

  def project do
    [
      app: :membership_mock,
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
      {:membership, in_umbrella: true},
      {:quantum, "~> 3.0-rc"}
    ]
  end
end
