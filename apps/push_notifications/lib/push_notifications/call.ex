defmodule PushNotifications.Call do
  @callback get_firebase_device_tokens(notification :: struct) :: [String.t()]
  @callback get_ios_device_tokens(notification :: struct) :: [String.t()]

  @callback prepare_firebase_body(notification :: struct, device_token :: String.t()) :: map
  @callback prepare_ios_body(notification :: struct) :: map

  @spec send(struct) :: :ok
  def send(notification) do
    :ok = send_firebase_notification(notification)
    :ok = send_ios_notification(notification)
  end

  defp send_firebase_notification(%notification_type{} = notification) do
    access_token = PushNotifications.Firebase.AccessToken.get_token()
    device_tokens = notification_type.get_firebase_device_tokens(notification)

    device_tokens
    |> Enum.each(fn device_token ->
      notification
      |> notification_type.prepare_firebase_body(device_token)
      |> PushNotifications.Firebase.FcmClient.send_notification(access_token, device_token)
    end)
  end

  defp send_ios_notification(%notification_type{} = notification) do
    device_tokens = notification_type.get_ios_device_tokens(notification)
    body = notification_type.prepare_ios_body(notification)

    device_tokens
    |> Enum.each(fn device_token ->
      PushNotifications.APNS.Client.send_call_notification(device_token, body)
    end)
  end
end
