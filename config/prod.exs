import Config

config :libcluster,
  topologies: [
    dronline_backend: [
      strategy: Cluster.Strategy.Kubernetes,
      config: [
        kubernetes_selector: "app=dronline-backend",
        kubernetes_node_basename: "app",
        polling_interval: 100
      ]
    ]
  ]

config :logger, level: :info

config :postgres, Postgres.Repo, pool_size: 10
