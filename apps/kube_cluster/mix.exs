defmodule KubeCluster.MixProject do
  use Mix.Project

  def project do
    [
      app: :kube_cluster,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps: deps(),
      deps_path: "../../deps",
      elixir: "~> 1.8",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {KubeCluster.Application, []}
    ]
  end

  defp deps do
    [
      {:libcluster, "~> 3.3.0"}
    ]
  end
end
