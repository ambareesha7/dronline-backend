defmodule PushNotifications.Message do
  @callback get_device_tokens(notification :: struct) :: [String.t()]
  @callback prepare_body(notification :: struct, device_token :: String.t()) :: map

  @spec send(struct) :: :ok
  def send(%notification_type{} = notification) do
    access_token = PushNotifications.Firebase.AccessToken.get_token()
    device_tokens = notification_type.get_device_tokens(notification)

    device_tokens
    |> Enum.each(fn device_token ->
      notification
      |> notification_type.prepare_body(device_token)
      |> PushNotifications.Firebase.FcmClient.send_notification(access_token, device_token)
    end)
  end
end
