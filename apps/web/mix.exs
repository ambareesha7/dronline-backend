defmodule Web.Mixfile do
  use Mix.Project

  def project do
    [
      app: :web,
      build_path: "../../_build",
      compilers: Mix.compilers(),
      config_path: "../../config/config.exs",
      deps: deps(),
      deps_path: "../../deps",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      test_paths: ["lib"],
      test_pattern: "*.test.exs",
      version: "0.0.1",
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {Web.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:conductor, "~> 0.4.0"},
      {:corsica, "~> 1.1.3"},
      {:cowboy, "~> 2.10"},
      {:encode_anything, git: "https://git.appunite.com/tobiasz/encode_anything"},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:gettext, "~> 0.15"},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_view, "~> 0.20.0"},
      {:phoenix_pubsub, "~> 2.1.3"},
      {:plug_cowboy, "~> 2.6.1"},
      {:protobuf, "~> 0.7.1"},
      {:proto_response, "~> 0.1"},
      {:sentry, "~> 8.0"},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},

      # WIP
      {:ex_aws, "~> 2.4"},
      {:ex_aws_s3, "~> 2.4"},
      {:sweet_xml, "~> 0.7"},

      # umbrella
      {:admin, in_umbrella: true},
      {:authentication, in_umbrella: true},
      {:calls, in_umbrella: true},
      {:emr, in_umbrella: true},
      {:proto, in_umbrella: true},
      {:mailers, in_umbrella: true},
      {:membership, in_umbrella: true},
      {:membership_mock, in_umbrella: true},
      {:notifications_read, in_umbrella: true},
      {:patient_profile, in_umbrella: true},
      {:patient_profiles_management, in_umbrella: true},
      {:specialist_profile, in_umbrella: true},
      {:triage, in_umbrella: true},
      {:twilio, in_umbrella: true},
      {:upload, in_umbrella: true},
      {:visits, in_umbrella: true},
      {:visits_scheduling, in_umbrella: true},
      {:insurance, in_umbrella: true},
      {:feature_flags, in_umbrella: true},
      {:fun_with_flags_ui, "~> 0.9.0"},
      {:payouts, in_umbrella: true},
      {:urgent_care, in_umbrella: true}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind web", "esbuild web"],
      "assets.deploy": ["tailwind web --minify", "esbuild web --minify", "phx.digest"]
    ]
  end
end
