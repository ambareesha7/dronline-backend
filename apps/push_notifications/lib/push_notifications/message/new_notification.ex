defmodule PushNotifications.Message.NewNotification do
  @behaviour PushNotifications.Message

  @fields [:send_to_specialist_ids]

  @enforce_keys @fields
  defstruct @fields

  @impl true
  def get_device_tokens(%__MODULE__{} = n) do
    PushNotifications.Devices.SpecialistDevice.all_tokens_for_specialist_ids(
      n.send_to_specialist_ids
    )
  end

  @impl true
  def prepare_body(%__MODULE__{} = _n, device_token) do
    %{
      "message" => %{
        "token" => device_token,
        "notification" => %{
          "title" => "DrOnline",
          "body" => "You have received a new notification"
        },
        "data" => %{
          "action" => "new_notification",
          "click_action" => "FLUTTER_NOTIFICATION_CLICK"
        },
        "android" => %{
          "priority" => "high"
        },
        "apns" => %{
          "payload" => %{
            "aps" => %{
              "sound" => "notification_ring.caf"
            }
          }
        }
      }
    }
  end
end
