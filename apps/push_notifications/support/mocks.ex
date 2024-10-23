defmodule PushNotifications.OAuthClientMock do
  def create_access_token, do: {:ok, "token"}
end

defmodule PushNotifications.CallMock do
  def send(_notification), do: :ok
end
