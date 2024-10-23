[
  import_deps: [:ecto, :ecto_sql],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  subdirectories: ["priv/*/migrations"],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test,priv}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"]
]
