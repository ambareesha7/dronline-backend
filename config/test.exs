import Config

config :ex_unit, assert_receive_timeout: 250

config :ex_aws,
  access_key_id: "",
  region: "",
  secret_access_key: ""

config :logger, level: :warning

config :opentok,
  api_key: "test",
  api_url: "test",
  secret: "test"

config :oban, Oban, queues: false, plugins: false

config :patient_profile,
  default_boy_avatar_path: "/boy_test_default_avatar",
  default_girl_avatar_path: "/girl_test_default_avatar",
  default_man_avatar_path: "/man_test_default_avatar",
  default_other_avatar_path: "/other_test_default_avatar",
  default_woman_avatar_path: "/woman_test_default_avatar"

config :pbkdf2_elixir, rounds: 1

config :postgres, Postgres.Repo,
  username: "postgres",
  password: "postgres",
  database: "dronline_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  queue_target: 5000

config :twilio,
  account_sid: "test",
  key_sid: "test",
  key_secret: "test"

config :upload,
  client_email: "email@example.com",
  # random private key needed for tests to pass
  private_key:
    "-----BEGIN RSA PRIVATE KEY-----\nMIICXAIBAAKBgQCqGKukO1De7zhZj6+H0qtjTkVxwTCpvKe4eCZ0FPqri0cb2JZfXJ/DgYSF6vUp\nwmJG8wVQZKjeGcjDOL5UlsuusFncCzWBQ7RKNUSesmQRMSGkVb1/3j+skZ6UtW+5u09lHNsj6tQ5\n1s1SPrCBkedbNf0Tp0GbMJDyR4e9T04ZZwIDAQABAoGAFijko56+qGyN8M0RVyaRAXz++xTqHBLh\n3tx4VgMtrQ+WEgCjhoTwo23KMBAuJGSYnRmoBZM3lMfTKevIkAidPExvYCdm5dYq3XToLkkLv5L2\npIIVOFMDG+KESnAFV7l2c+cnzRMW0+b6f8mR1CJzZuxVLL6Q02fvLi55/mbSYxECQQDeAw6fiIQX\nGukBI4eMZZt4nscy2o12KyYner3VpoeE+Np2q+Z3pvAMd/aNzQ/W9WaI+NRfcxUJrmfPwIGm63il\nAkEAxCL5HQb2bQr4ByorcMWm/hEP2MZzROV73yF41hPsRC9m66KrheO9HPTJuo3/9s5p+sqGxOlF\nL0NDt4SkosjgGwJAFklyR1uZ/wPJjj611cdBcztlPdqoxssQGnh85BzCj/u3WqBpE2vjvyyvyI5k\nX6zk7S0ljKtt2jny2+00VsBerQJBAJGC1Mg5Oydo5NwD6BiROrPxGo2bpTbu/fhrT8ebHkTz2epl\nU9VQQSQzY1oZMVX8i1m5WUTLPz2yLJIBQVdXqhMCQBGoiuSoSjafUhV7i1cEGpb88h5NBYZzWXGZ\n37sJ5QsW+sJyoNde3xH8vdXhzU7eT82D6X/scw9RZz+/6rCJ4p0=\n-----END RSA PRIVATE KEY-----"

config :visits, :telr,
  authkey: "",
  store_id: "",
  test_env: "1",
  remote_api_url: ""

config :pdf_generator,
  raise_on_missing_wkhtmltopdf_binary: false
