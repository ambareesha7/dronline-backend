defmodule OpenTok.Authentication do
  alias OpenTok.Helpers

  defp api_key, do: Application.get_env(:opentok, :api_key)
  defp secret, do: Application.get_env(:opentok, :secret)

  @expiration_time_in_minutes 2

  @doc """
  Generates token used to authenticate API requests
  """
  @spec generate_token() :: String.t()
  def generate_token do
    now = Timex.now()

    iss = api_key()
    ist = "project"
    iat = now |> Timex.to_unix() |> to_string()

    exp =
      now
      |> Timex.shift(minutes: @expiration_time_in_minutes)
      |> Timex.to_unix()
      |> to_string()

    jti = Helpers.nonce()

    {:ok, token, _claims} =
      %{}
      |> Joken.Config.add_claim("iss", fn -> iss end, &(&1 == iss))
      |> Joken.Config.add_claim("ist", fn -> ist end, &(&1 == ist))
      |> Joken.Config.add_claim("iat", fn -> iat end, &(&1 == iat))
      |> Joken.Config.add_claim("exp", fn -> exp end, &(&1 == exp))
      |> Joken.Config.add_claim("jti", fn -> jti end, &(&1 == jti))
      |> Joken.generate_and_sign(%{}, Joken.Signer.create("HS256", secret()))

    token
  end
end
