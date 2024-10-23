defmodule OpenTok.Tokens do
  alias OpenTok.Helpers

  defp api_key, do: Application.get_env(:opentok, :api_key)
  defp secret, do: Application.get_env(:opentok, :secret)

  @doc """
  Generates invidual token which allows clients to connect to given session
  """
  @spec generate(String.t()) :: String.t()
  def generate(session_id) do
    token_data = prepare_token_data(session_id)

    token_data
    |> sign_token_data()
    |> prepare_token_header()
    |> generate_token(token_data)
  end

  defp generate_token(token_header, token_data) do
    token =
      "#{token_header}:#{token_data}"
      |> Base.encode64()

    "T1==#{token}"
  end

  defp prepare_token_data(session_id) do
    now = Timex.now()

    %{
      "session_id" => session_id,
      "create_time" => Timex.to_unix(now),
      "role" => "publisher",
      "nonce" => Helpers.nonce(),
      "expire_time" => now |> Timex.shift(days: 1) |> Timex.to_unix()
    }
    |> URI.encode_query()
  end

  defp prepare_token_header(sig) do
    %{
      "partner_id" => api_key(),
      "sig" => "#{sig}"
    }
    |> URI.encode_query()
  end

  defp sign_token_data(token_data) do
    :hmac |> :crypto.mac(:sha, secret(), token_data) |> Base.encode16()
  end
end
