defmodule PushNotifications.APNS.AccessToken do
  use GenServer

  @env Mix.env()
  @refresh_interval :timer.minutes(50)

  @spec get_token :: String.t()
  def get_token do
    [{:access_token, token}] = :ets.lookup(__MODULE__, :access_token)

    token
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, @env, name: __MODULE__)
  end

  @impl true
  def init(:prod) do
    __MODULE__ = :ets.new(__MODULE__, [:protected, :named_table, read_concurrency: true])
    send(self(), :create_new_access_token)

    {:ok, []}
  end

  @impl true
  def init(_) do
    :ignore
  end

  @impl true
  def handle_info(:create_new_access_token, state) do
    new_token = create_access_token()

    :ets.insert(__MODULE__, {:access_token, new_token})
    Process.send_after(self(), :create_new_access_token, @refresh_interval)

    {:noreply, state}
  end

  def create_access_token do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()

    header = %{
      "alg" => "ES256",
      "kid" => key_id()
    }

    pem_key = private_key() |> String.replace("\\n", "\n")
    signer = Joken.Signer.create("ES256", %{"pem" => pem_key}, header)

    iss = team_id()
    iat = timestamp
    kty = "RSA"

    {:ok, token, _claims} =
      %{}
      |> Joken.Config.add_claim("iss", fn -> iss end, &(&1 == iss))
      |> Joken.Config.add_claim("iat", fn -> iat end, &(&1 == iat))
      |> Joken.Config.add_claim("kty", fn -> kty end, &(&1 == kty))
      |> Joken.generate_and_sign(%{}, signer)

    token
  end

  defp private_key, do: Application.get_env(:push_notifications, :apns_private_key)
  defp team_id, do: Application.get_env(:push_notifications, :apns_team_id)
  defp key_id, do: Application.get_env(:push_notifications, :apns_key_id)
end
