defmodule DrOnline.Umbrella.Mixfile do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      apps_path: "apps",
      deps: deps(),
      dialyzer: dialyzer(),
      start_permanent: Mix.env() == :prod,
      version: version(),
      releases: [
        app: [
          include_executables_for: [:unix],
          applications: [
            runtime_tools: :permanent,
            postgres: :permanent,
            web: :permanent,
            teams_web: :permanent,
            kube_cluster: :permanent
          ]
        ]
      ]
    ]
  end

  defp deps do
    [
      {:clipboard, "~> 0.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7.1", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.4"},
      # Required to run "mix format" on ~H/.heex files from the umbrella root
      {:phoenix_live_view, ">= 0.0.0"}
    ]
  end

  defp dialyzer do
    [
      flags: [:error_handling, :race_conditions, :underspecs, :unmatched_returns],
      ignore_warnings: ".dialyzerignore",
      plt_add_apps: [:mix]
    ]
  end

  defp aliases do
    [
      credo: ["credo --strict"],
      "ecto.reset": ["ecto.drop", "ecto.create", "ecto.migrate"],
      test: ["test"]
    ]
  end

  defp version do
    File.read!("VERSION")
  end
end
