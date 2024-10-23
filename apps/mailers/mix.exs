defmodule Mailers.MixProject do
  use Mix.Project

  def project do
    [
      app: :mailers,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps: deps(),
      deps_path: "../../deps",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application do
    [
      extra_applications: [:eex, :logger],
      mod: {Mailers.Application, []}
    ]
  end

  defp deps do
    [
      {:encode_anything, git: "https://git.appunite.com/tobiasz/encode_anything"},
      {:mockery, "~> 2.3"},
      {:sentry, "~> 8.0"},
      {:tesla, "~> 1.7"},
      {:timex, "~> 3.7"},
      {:oban, "~> 2.10.1"},
      {:pdf_generator, "~> 0.6.2"},
      {:sneeze, "~> 2.0"},
      # umbrella
      {:firebase, in_umbrella: true}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "support"]
  defp elixirc_paths(_), do: ["lib"]
end
