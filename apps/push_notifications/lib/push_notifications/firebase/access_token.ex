defmodule PushNotifications.Firebase.AccessToken do
  use GenServer

  import Mockery.Macro

  alias PushNotifications.Firebase.OAuthClient

  @refresh_interval :timer.minutes(30)
  @retry_interval :timer.minutes(1)

  @spec get_token :: String.t()
  def get_token do
    [{:access_token, token}] = :ets.lookup(__MODULE__, :access_token)

    token
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    __MODULE__ = :ets.new(__MODULE__, [:protected, :named_table, read_concurrency: true])
    send(self(), :create_new_access_token)

    {:ok, []}
  end

  def handle_info(:create_new_access_token, state) do
    case oauth_client().create_access_token() do
      {:ok, new_token} ->
        :ets.insert(__MODULE__, {:access_token, new_token})
        Process.send_after(self(), :create_new_access_token, @refresh_interval)

        {:noreply, state}

      :error ->
        Process.send_after(self(), :create_new_access_token, @retry_interval)

        {:noreply, state}
    end
  end

  defp oauth_client, do: mockable(OAuthClient, by: PushNotifications.OAuthClientMock)
end
