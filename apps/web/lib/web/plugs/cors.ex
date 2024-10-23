defmodule Web.Plugs.CORS do
  use Corsica.Router,
    origins: {__MODULE__, :check_corsica_origin},
    allow_credentials: true,
    allow_headers: [
      "accept",
      "authorization",
      "content-type",
      "origin",
      "referer",
      "x-auth-token"
    ]

  resource("/admin_api/*")
  resource("/api/*")
  resource("/panel_api/*")
  resource("/public_api/*")
  resource("/landing_api/*", allow_headers: :all)

  def check_corsica_origin(origin) do
    origin = remove_localhost_port(origin)

    origin in String.split(Application.get_env(:web, :whitelisted_domain), ",")
  end

  defp remove_localhost_port(origin) do
    String.replace(origin, ~r/(http:\/\/localhost):\d+/, "\\1")
  end
end
