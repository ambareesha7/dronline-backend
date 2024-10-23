defmodule PushNotifications.Firebase.FcmClient do
  import Mockery.Macro

  alias PushNotifications.Devices.PatientDevice
  alias PushNotifications.Devices.SpecialistDevice

  @spec send_notification(map, String.t(), String.t()) :: :ok | :error
  def send_notification(body, access_token, device_token) do
    middlewares = [
      Tesla.Middleware.Logger,
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers,
       [
         {"Authorization", "Bearer #{access_token}"}
       ]}
    ]

    middlewares
    |> Tesla.client()
    |> mockable(Tesla).post(firebase_url(), body)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: _body}} ->
        :ok

      result ->
        _ = handle_not_found_error(result, device_token)

        _ =
          Sentry.capture_message(
            "PushNotifications.Firebase.FcmClient.send_notification/3 failure",
            extra: %{
              body: body,
              result: result
            },
            result: :none
          )

        :error
    end
  end

  defp firebase_url, do: Application.get_env(:push_notifications, :fcm_url)

  @doc """
  Handle 404 Firebase API error by removing token from database.

  body: {
    error: {
      code: 404, 
      details: [
        {"@type":"type.googleapis.com/google.firebase.fcm.v1.FcmError","errorCode":"UNREGISTERED"}
      ], 
      message: Requested entity was not found., 
      status: NOT_FOUND
    }
  }

  Steps to reproduce:
  - re-install the app (old Specialist or Patient device token remains in database)
  - send any FCM notification, for example - from Patient app schedule a Visit,
    to trigger "You have a scheduled visit" notification
  - observe abovementioned error in Sentry
  """
  def handle_not_found_error({:ok, %Tesla.Env{status: 404}}, device_token) do
    Sentry.Context.set_extra_context(%{removed_device_token: device_token})

    :ok = PatientDevice.unregister(device_token)
    :ok = SpecialistDevice.unregister(device_token)

    :ok
  end

  def handle_not_found_error(_, _), do: :ok
end
