import Config

random_priv_key = """
-----BEGIN RSA PRIVATE KEY-----
MIIJKAIBAAKCAgEAyP5Q1+ZKmtFFON/V20OjkKI+qCRXBDCMnEHgUAcjjH3IiXj9
GTbkKSw+8BGNpDRzpMbEp43SZ/Ohb0dq3QrimrKYUXUl4yDHfKJeJ2noEbq4A4cL
YqXSnUddCGTyljdTZbTTNlLLmnq+Y/soo+d+8f7DlfW67ZJskpm+xJdBB3/8loXb
vk1aGhw+6JEwWRSaTHnXdFclgrzxlSqX3/kmQgNLcNGtuWrsGwTj3HD4eF44fF1z
I00nnoflYHVIpLQsgA3pxWYJCrNhp0RJvTJhYfKJMH6gPfPPD5mreEMOSR38LQXM
fxc6eKb6idk/qcC90PE+XQzWlh+So1ObezQy36sEwoQbW34biT4Wil7hy5J8CKHA
1uA4/koPH2n1ga7X0+GBmm0dlwxS7c7jfzQhS57Bk0mlvqDYR0Be0ImcslHGIrhK
ifha074u+U4I+TyMR+VftcYwcQvsCaTb+OlJWkvoTPUn3s4q2TAcHeitquBPBYvU
nqFuzU4oBab3RaxyIjihhe0dg/dShl1xZlonfW/QiQPrc/m9hOJy/4zhN67TALL+
UZwSI3kS2+1cLp2V5mXU9Xpnx7LWyY/UeobzTE32XFg3qz8mGq6WDeoXBWnOALhU
yA4DE4YAZogJqIitu9kstYv0wPWC9lBWzpLy+QtRXZdjtZbwODen6Q2nbrUCAwEA
AQKCAgEAscPT5o+kjjbmXT4DG/E/ucz1U6sIVwlFY3IUHVOjCj+5XHTojSNyOkQK
yjMMLh3B5gtypKqXXB8rOYtVpXhaIO4yL2FICBDWvpGwanWNrhiRZXVMCYyVsUsL
qj/2GguGtB5w68vgjZlfyHe7YvN84DUt8PSrxjDJ3AMkqSUJe8Ojt9FeH3q0ZQF0
VicLNs41BcyBVUE6SN4pYH+SYaIvRxU45OheGO7LMb5qdW5pI7RZiwzvp1o230xb
/6rbe+hqrzse9dqfxpoOlWydNztWy9VBpuVnfkOjb62+7ReJi/t8LKnDSuhVa55r
Wf4OA2oXt7OWL6AKLi5weAmbKyVok7yxRGGWN9zTzaZCpm0nZZVD+1f+CVCzrxD8
8KNrrNj6BMVALgrG6/mFsg2LPS/Gh4zfWHFZmFOGcXnHBH2iTjjo02UR8ZXtI4gu
yAj9Z+LBJxs/7OiteiX8WxlMcdjuXGmZnRyPn6MXcszzLlunMgWxd2VnZNaqWR3v
9R8Wrz+8szEC9wNe6KzGeiZ890XCO+tsuhUiLXvX1h3AKvBAg85vmQTht6bhX50+
CyqEjacy12w35/goYrcaNHOGoOa7FcWsNyMHN7hQQ+B6oJuiAUBWd6+kxU696COR
JZ2fGo08LZ7mYNwY+7Zy3kausHud6qiRyfRtqK21Nt7EmQHrzAUCggEBAPpPQO+Y
wKf+7cqVDkzF3NtMNlunttdI5Mrb9/8WTfs0GjTNPv/DLo+kXq3NKXCJHL9BaHY3
iimx8aPON3zYiWAZ2o4SICxirZLME32yM0CRsoTkp9+/o5Tmhp/+jyIv4ohGh7Sa
xbv8LBLTvcc2d4oHDi10Hq81C59Git8W0ArVkZrZ7g33tMlhZHvLSPXCYj6lJoiH
9RpztkiEIE4In+OgZ4pGpm1CAJpn/k1cJYe2vKA67gKGVhxCwiEl35nN70P8mwvD
gigoCErR+6nLLHx42VoLR+x5Bnjpi5kTUbwtRpPCisTtMapLOVsYvQV98V9/YpR9
y9tNlNI37D7/QHcCggEBAM2QDZCzTggEObYZHxxcYFxiGg/ABMbZBPhMgKdLTT6Y
daqdnV4KejjhKFzMbJouYJkPguvEDnN9SMM/bHzg3li2WJPXlKJQJeYNkDvynlKK
MdMfXD+H4nNboYNHdbSRA99b+eE04BEsynKf/anCgVN3MDPB8UELKq2OMyJiAYsR
xfK7g4J2BypynUyi5622fhX9wAI9aI81loVgfsIkHMBpFqIB8MJvB8nxGe1KxKj0
t8iHR6MOTKL9QJkE8rIxbosGTJEJqNMeOVLBW+6ssyH0EDYmvxVHHiZweexyLzl5
WRWA2hRXzlSHoIIWnB4yUNtPYQeXGkCRIfexAoZD4TMCggEAXAgHuBBRxXLVu0ZS
m6ekLH04/zoK39zNQkjeRcvNoC7n88IDB8abt/SXWw+zzMyc5TUHU2/YPLxQPAn2
HNEAsXTQBqxjZ+5gIzklcXGzpmnrWTE5B+tOGdEobmsJ9WflwnUsMBs32IY/Lizr
+fLswLMXY17uaTz3qPgm1x9sHo+nmWfHPxt0PRax+1Ii4Tk3JhFSuaBDXhZtTvxF
ZGuHXgn8B7syNbmuvxa9SXQ32E43zDHekM8TmhBxj/581+//qN+XohugH2OYqOnL
vgIVuS41vAWpzCgzWQGFciLISofbCzjcDMupFxPRYs0Vso870ADmHfKioV9E+IXX
NtJiwQKCAQAbqJBKsfWD2p2xRLwM4tkMVR7Qk7OQ1c53YkPFPrqL+5OJe1+bMam0
UYdOxSqvrCHPNmkVM/IF1AugSb5dJxyDrzVH3y/ejw4qYBTSHBj1XibKE2QkIDJ1
9xRKR6ksvH5a5VM/3A9yACbVOXW2C7e+9UCFFklRySDa7VEwBSPUBHYv7M8LFLpu
GbHUh+7ITs+0Qco+Auk4q6svEwa7NISx1vH2pnAwmSPhJhGo/fBsE1FPJ/SZmejx
3UV90U6eb0xCZHyU30nZ7i0kV2P5Pz9zCBXOU3ROdp016thc2hhEkXFNFWNCbXYT
pZQRLN2gqoB6obmafdhIa764Rxbh3exFAoIBAAkvaKIIPnE9rzBub/u9/Y415QFY
doDD7iYvcJ1K7Uyq9ORU171cevYa7q3CsFirSDh1YCIlGysluh+GD2yVPIQRk0Tk
Hp/O4bxUAoh8/w1SNwPyt9MXY3bMCFbjNIOLDx1aVd6DN9Rk0BBlEs0ErX93h39G
R6l6utRKQpRggblpC74ejlQHrDP7NJbE5wK+Qq3d6ZGgTsQ05lCF0Y9tYpnSMWV6
CGjzAIzprqiXKQVPMH/7wvSkucdGRl065YVDOwfS1/qSCb/UsvbCs/06MQOyqjpS
fw5x+zgr1UTh06vZHIvN5JC84Sv7ZYyUAZCiQe0gB86TZiVxFbSlleTGp4Y=
-----END RSA PRIVATE KEY-----
"""

config :emr,
  tokbox_aws_bucket: System.get_env("TOKBOX_AWS_BUCKET") || "",
  tokbox_id: System.get_env("TOKBOX_API_KEY") || "",
  video_processing_temp_dir: "/tmp"

config :ex_aws,
  access_key_id: System.get_env("TOKBOX_AWS_KEY_ID"),
  region: System.get_env("TOKBOX_AWS_REGION"),
  secret_access_key: System.get_env("TOKBOX_AWS_SECRET")

config :firebase, api_key: System.get_env("DRONLINE_FIREBASE_API_KEY")

config :logger, :console, format: "[$level] $message\n"

config :mailers, sparkpost_api_key: "dffac1ec70ff0751dd02b71ae713dac939c4f83d"

config :membership,
  authkey: System.get_env("TELR_AUTHKEY"),
  basic_auth_name: System.get_env("TELR_BASIC_AUTH_NAME"),
  basic_auth_password: System.get_env("TELR_BASIC_AUTH_PASSWORD"),
  gateway_url: System.get_env("TELR_GATEWAY_URL"),
  store_id: System.get_env("TELR_STORE_ID"),
  test_env: System.get_env("TELR_TEST_ENV"),
  tools_url: System.get_env("TELR_TOOLS_URL")

config :push_notifications,
  fcm_issuer: System.get_env("DRONLINE_FCM_ISSUER") || "",
  fcm_private_key: System.get_env("DRONLINE_FCM_PRIVATE_KEY") || random_priv_key,
  fcm_url: System.get_env("DRONLINE_FCM_URL") || "",
  apns_key_id: System.get_env("DRONLINE_APNS_KEY_ID") || "",
  apns_private_key: System.get_env("DRONLINE_APNS_PRIVATE_KEY") || "",
  apns_team_id: System.get_env("DRONLINE_APNS_TEAM_ID") || "",
  apns_topic_url: System.get_env("DRONLINE_APNS_TOPIC_URL") || "",
  apns_url: System.get_env("DRONLINE_APNS_URL") || ""

config :opentok,
  api_url: System.get_env("TOKBOX_API_URL"),
  api_key: System.get_env("TOKBOX_API_KEY"),
  secret: System.get_env("TOKBOX_SECRET")

config :phoenix, :plug_init_mode, :runtime
config :phoenix, :stacktrace_depth, 20

config :postgres, Postgres.Repo,
  username: "postgres",
  password: "postgres",
  database: "dronline_dev",
  hostname: "localhost",
  pool_size: 10

config :twilio,
  account_sid: System.get_env("DRONLINE_TWILIO_ACCOUNT_SID"),
  key_sid: System.get_env("DRONLINE_TWILIO_KEY_SID"),
  key_secret: System.get_env("DRONLINE_TWILIO_KEY_SECRET"),
  messege_service_sid: System.get_env("DRONLINE_TWILIO_MESSAGE_SERVICE_SID")

config :upload,
  private_key: System.get_env("GCS_PRIVATE_KEY") || "",
  client_email: System.get_env("GCS_CLIENT_EMAIL") || "",
  thumbor_url: System.get_env("THUMBOR_URL") || ""

config :web, Web.Endpoint,
  http: [port: 4000],
  https: [
    port: 4001,
    certfile: "priv/cert/selfsigned.pem",
    keyfile: "priv/cert/selfsigned_key.pem"
  ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]}],
  # not sure if it should stay
  server: true

config :teams_web, TeamsWeb.Endpoint,
  http: [port: 4002],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]}]

config :visits, :telr,
  authkey: System.get_env("TELR_REMOTE_API_KEY"),
  payment_authkey: System.get_env("TELR_AUTHKEY"),
  store_id: System.get_env("TELR_STORE_ID"),
  test_env: System.get_env("TELR_TEST_ENV"),
  remote_api_url: System.get_env("TELR_REMOTE_API_URL"),
  hosted_payment_api_url: System.get_env("TELR_GATEWAY_URL")
