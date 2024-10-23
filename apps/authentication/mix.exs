defmodule Authentication.MixProject do
  use Mix.Project

  def project do
    [
      app: :authentication,
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
      extra_applications: [:eex, :logger],
      mod: {Authentication.Application, []}
    ]
  end

  defp deps do
    [
      # deps
      {:encode_anything, git: "https://git.appunite.com/tobiasz/encode_anything"},
      {:joken, "~> 2.4.0"},
      {:mockery, "~> 2.3"},
      {:pbkdf2_elixir, "~> 2.1"},
      # TODO upgrade joken and remove poison
      {:poison, "~> 3.1"},
      {:sentry, "~> 8.0"},

      # umbrella
      {:firebase, in_umbrella: true},
      {:patient_profile, in_umbrella: true},
      {:postgres, in_umbrella: true},
      {:mailers, in_umbrella: true},
      # initialize atoms
      {:admin, in_umbrella: true},
      {:proto, in_umbrella: true},
      {:specialist_profile, in_umbrella: true}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "support"]
  defp elixirc_paths(_), do: ["lib"]
end
