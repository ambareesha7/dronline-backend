defmodule KubeCluster.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies)

    children = [
      {Cluster.Supervisor, [topologies, [name: KubeCluster.ClusterSupervisor]]}
    ]

    opts = [strategy: :one_for_one, name: KubeCluster.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
