defmodule Firebase.Authentication do
  @doc """
  Validates firebase authentication token
  """
  use Joken.Config

  @spec validate_token(String.t()) :: {:ok, map()} | {:error, atom() | Keyword.t()}
  def validate_token(token) do
    with {:ok, kid} <- fetch_kid(token),
         {:ok, public_key} <- Firebase.Authentication.PublicKeys.fetch_key(kid) do
      verification(token, public_key)
    end
  end

  @spec fetch_kid(String.t()) :: {:ok, String.t()} | {:error, atom()}
  defp fetch_kid(token_struct) do
    {:ok, headers} =
      token_struct
      |> Joken.peek_header()

    Map.fetch(headers, "kid")
  rescue
    ArgumentError -> {:error, :argument_error}
    MatchError -> {:error, :match_error}
  end

  @spec verification(String.t(), String.t()) :: {:ok, map} | {:error, atom() | Keyword.t()}
  defp verification(token, public_key) do
    project_name = Application.get_env(:firebase, :project_name)
    {:ok, claims} = Joken.peek_claims(token)

    phone_number = Map.get(claims, "phone_number")
    sub = Map.get(claims, "sub")

    claims
    |> delete_unhandled_keys()
    |> add_claim("exp", nil, &(&1 >= Joken.current_time()))
    |> add_claim("iat", nil, &(&1 <= Joken.current_time()))
    |> add_claim("auth_time", nil, &(&1 <= Joken.current_time()))
    |> add_claim("aud", nil, &(&1 == project_name))
    |> add_claim("iss", nil, &(&1 == "https://securetoken.google.com/#{project_name}"))
    |> add_claim("phone_number", fn -> phone_number end, &(&1 == phone_number))
    |> add_claim("sub", fn -> sub end, &(&1 == sub))
    |> Joken.verify_and_validate(
      token,
      Joken.Signer.create("RS256", %{"pem" => public_key})
    )
  end

  defp delete_unhandled_keys(claims) do
    claims
    |> Map.delete("firebase")
    |> Map.delete("user_id")
  end
end
