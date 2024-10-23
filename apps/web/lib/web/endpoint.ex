defmodule Web.Endpoint do
  use Sentry.PlugCapture
  use Phoenix.Endpoint, otp_app: :web

  # Because new version of Sobelow marks all possible values for `websocket` option as
  # possible CSWH - `Cross-Site Websocket Hijacking - Low Confidence`. We have added
  # `Config.CSWH` to ignore option in `run_sobelow.sh` script
  socket "/channels", Web.Socket,
    longpoll: false,
    websocket: [
      serializer: [{Web.Channels.ProtoSerializer, "~> 2.0.0"}],
      check_origin: {__MODULE__, :check_socket_origin, []}
    ]

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug Web.Plugs.CORS
  plug Plug.RequestId
  plug Web.Router

  plug Sentry.PlugContext

  plug Plug.Static,
    at: "/",
    from: :web,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)

  # Callback invoked for dynamically configuring the endpoint.
  #
  # It receives the endpoint configuration and checks if
  # configuration should be loaded from the system environment.
  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end

  def check_socket_origin(%URI{} = uri) do
    origin = uri.scheme <> "://" <> uri.host
    origin in String.split(Application.get_env(:web, :whitelisted_domain), ",")
  end
end
