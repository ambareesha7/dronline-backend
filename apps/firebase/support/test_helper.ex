defmodule Firebase.TestHelper do
  @project_name Application.compile_env(:firebase, :project_name)
  @test_priv_key """
  -----BEGIN RSA PRIVATE KEY-----
  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
  -----END RSA PRIVATE KEY-----
  """

  def firebase_auth_token(expiration_day, firebase_id \\ nil, phone_number \\ nil) do
    exp = parse_expiration(expiration_day)

    header = %{
      "kid" => "test"
    }

    pem_key = @test_priv_key |> String.replace("\\n", "\n")
    signer = Joken.Signer.create("RS256", %{"pem" => pem_key}, header)

    phone_number = phone_number || "+48123456789"
    firebase_id = firebase_id || to_string(System.unique_integer())
    iss = "https://securetoken.google.com/#{@project_name}"

    {:ok, token, _claims} =
      %{}
      |> Joken.Config.add_claim("auth_time", fn -> 0 end, &(&1 == 0))
      |> Joken.Config.add_claim("iss", fn -> iss end, &(&1 == iss))
      |> Joken.Config.add_claim("iat", fn -> 0 end, &(&1 == 0))
      |> Joken.Config.add_claim("exp", fn -> exp end, &(&1 == exp))
      |> Joken.Config.add_claim("aud", fn -> @project_name end, &(&1 == @project_name))
      |> Joken.Config.add_claim("sub", fn -> firebase_id end, &(&1 == firebase_id))
      |> Joken.Config.add_claim("phone_number", fn -> phone_number end, &(&1 == phone_number))
      |> Joken.Config.add_claim("firebase", fn ->
        %{"identities" => %{"phone_number" => [phone_number], "sign_in_provider" => "phone"}}
      end)
      |> Joken.Config.add_claim("user_id", fn -> firebase_id end)
      |> Joken.generate_and_sign(nil, signer)

    token
  end

  defp parse_expiration(expiration) do
    "#{expiration}T00:00:00"
    |> NaiveDateTime.from_iso8601!()
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_unix()
  end
end
