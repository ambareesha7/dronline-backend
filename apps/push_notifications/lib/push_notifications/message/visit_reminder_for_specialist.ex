defmodule PushNotifications.Message.VisitReminderForSpecialist do
  @behaviour PushNotifications.Message

  @fields [
    :specialist_id,
    :patient_id,
    :record_id,
    :time_till_visit
  ]

  @enforce_keys @fields
  defstruct @fields

  @impl true
  def get_device_tokens(%__MODULE__{} = n) do
    PushNotifications.Devices.SpecialistDevice.all_tokens_for_specialist_id(n.specialist_id)
  end

  @impl true
  def prepare_body(%__MODULE__{} = n, device_token) do
    time_till_msg =
      case n.time_till_visit do
        :starting -> "right now"
        :upcoming -> "in 10 minutes"
      end

    %{
      "message" => %{
        "token" => device_token,
        "notification" => %{
          "title" => "DrOnline",
          "body" => "You have a scheduled visit #{time_till_msg}"
        },
        "data" => %{
          "action" => "visit_reminder_for_specialist",
          "click_action" => "FLUTTER_NOTIFICATION_CLICK",
          "patient_id" => to_string(n.patient_id),
          "record_id" => to_string(n.record_id)
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
