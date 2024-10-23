defmodule PushNotifications.Firebase.OAuthClient do
  @seconds_in_hour 3600

  @spec create_access_token() :: {:ok, String.t()} | :error
  def create_access_token do
    middlewares = [
      Tesla.Middleware.FormUrlencoded,
      Tesla.Middleware.DecodeJson
    ]

    {:ok, jwt, _extra_headers} = create_jwt_token()

    body = %{
      "grant_type" => "urn:ietf:params:oauth:grant-type:jwt-bearer",
      "assertion" => jwt
    }

    middlewares
    |> Tesla.client()
    |> Tesla.post("https://www.googleapis.com/oauth2/v4/token", body)
    |> case do
      {:ok, %Tesla.Env{body: %{"access_token" => token}}} ->
        {:ok, token}

      result ->
        message = "PushNotifications.Firebase.OAuthClient.create_access_token/0 failure"
        _ = Sentry.capture_message(message, extra: %{result: result})

        :error
    end
  end

  @spec create_jwt_token() :: {:ok, String.t(), map()} | {:error, atom() | Keyword.t()}
  defp create_jwt_token do
    key = Application.get_env(:push_notifications, :fcm_private_key)
    issuer = Application.get_env(:push_notifications, :fcm_issuer)
    timestamp = DateTime.utc_now() |> DateTime.to_unix()

    pem_key = key |> String.replace("\\n", "\n")
    signer = Joken.Signer.create("RS256", %{"pem" => pem_key})

    header = %{
      "alg" => "RS256",
      "typ" => "JWT"
    }

    exp = timestamp + @seconds_in_hour
    aud = "https://www.googleapis.com/oauth2/v4/token"
    scope = "https://www.googleapis.com/auth/firebase.messaging"

    %{}
    |> Joken.Config.add_claim("iss", fn -> issuer end, &(&1 == issuer))
    |> Joken.Config.add_claim("iat", fn -> timestamp end, &(&1 == timestamp))
    |> Joken.Config.add_claim("exp", fn -> exp end, &(&1 == exp))
    |> Joken.Config.add_claim("aud", fn -> aud end, &(&1 == aud))
    |> Joken.Config.add_claim("scope", fn -> scope end, &(&1 == scope))
    |> Joken.generate_and_sign(header, signer)
  end
end
