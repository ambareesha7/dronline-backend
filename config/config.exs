import Config

config :conductor, on_auth_failure: :send_resp

config :oban, Oban,
  queues: [mailers: 20],
  repo: Postgres.Repo

config :firebase,
  landing_page_url: "https://dronline-landing.appunite.net",
  project_name: "dronline-appunite",
  dynamic_link_domain: "dronlinetest.page.link",
  specialist_android_package_name: "com.dronline.doctor.dev",
  patient_android_package_name: "com.dronline.dev",
  specialist_ios_bundle_id: "com.appunite.dronline.doctor",
  patient_ios_bundle_id: "com.appunite.dronline",
  specialist_ios_appstore_id: "1451196028",
  patient_ios_appstore_id: "1381359305"

config :libcluster, topologies: []

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :membership,
  gateway_url: "https://secure.telr.com/gateway/order.json",
  test_env: "1"

config :visits, Visits.VisitReminders.Scheduler,
  jobs: [
    # Every minute
    {"* * * * *", {Visits.VisitReminders, :remind_about_visits, [[log: false]]}}
  ]

config :visits, MembershipMock.EndTrials.Scheduler,
  jobs: [
    # Every night
    {"0 0 * * *", {MembershipMock.EndTrials, :end_trials, []}}
  ]

config :mime, :types, %{"application/x-protobuf" => ["proto"]}

config :phoenix, :format_encoders, proto: ProtoEngine

config :phoenix, :json_library, Jason

config :postgres, ecto_repos: [Postgres.Repo]

config :postgres,
       Postgres.Repo,
       migration_timestamps: [type: :naive_datetime_usec],
       types: Postgres.PostgrexTypes

config :sentry,
  dsn: "",
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  included_environments: ["production", "staging", "development", "localhost"],
  environment_name: "none",
  json_library: EncodeAnything

config :tzdata, :autoupdate, :disabled

config :upload,
  base_url: "https://storage.googleapis.com",
  bucket: "dronline-dev",
  private_key: "",
  client_email: "",
  thumbor_url: ""

config :web,
  namespace: Web,
  ecto_repos: [Postgres.Repo]

config :web, Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CYOZn1J41NPC+RWCsGeZ3AQ3b1n+H1hHfxRxeaggoNqiTwm+G1fVGpUU8UXnAqDd",
  render_errors: [view: Web.ErrorView, accepts: ["proto"]],
  check_origin: {Web.Endpoint, :check_socket_origin, []},
  pubsub_server: Web.PubSub

config :teams_web, TeamsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SA+2s7jC19CNDkknWy8BMHpNT3FfzhUXl5PJab+o/2RYcBYcmrGyYFyqaZJqsHtW",
  render_errors: [view: TeamsWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: TeamsWeb.PubSub

config :web, :generators, context_app: :postgres

config :web,
  channels_token_salt: "5iSu4gvmQfezdtWxVk8N9i4K02Z3ruSooLJ5JK27IZwvLBUA5W9Y6H6jfawty8dM",
  specialist_panel_url: "http://localhost:3000",
  support_email: "support@dronline-backend.appunite.net",
  whitelisted_domain: System.get_env("WEB_DOMAINS") || ""

config :fun_with_flags, :cache, enabled: false
config :fun_with_flags, :cache_bust_notifications, enabled: false

config :fun_with_flags, :persistence,
  adapter: FunWithFlags.Store.Persistent.Ecto,
  repo: Postgres.Repo

config :membership_mock, env: Mix.env()
config :visits, env: Mix.env()
config :urgent_care, default_clinic_id: "1"

config :esbuild,
  version: "0.17.11",
  web: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  teams_web: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/teams_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.3.2",
  web: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/web/assets", __DIR__)
  ],
  teams_web: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/teams_web/assets", __DIR__)
  ]

import_config "#{config_env()}.exs"
