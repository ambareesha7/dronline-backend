defmodule PushNotifications.Message.VisitReminderForPatient do
  @behaviour PushNotifications.Message

  @fields [
    :record_id,
    :send_to_patient_id,
    :time_till_visit
  ]

  @enforce_keys @fields
  defstruct @fields

  @impl true
  def get_device_tokens(%__MODULE__{} = n) do
    PushNotifications.Devices.PatientDevice.all_tokens_for_patient_id(n.send_to_patient_id)
  end

  @impl true
  def prepare_body(%__MODULE__{} = n, device_token) do
    time_till_msg =
      case n.time_till_visit do
        :starting -> "Wait for the specialist to call you"
        :upcoming -> "You have a scheduled visit in 10 minutes"
      end

    %{
      "message" => %{
        "token" => device_token,
        "notification" => %{
          "title" => "Open your app",
          "body" => "#{time_till_msg}"
        },
        "data" => %{
          "action" => "visit_reminder",
          "click_action" => "FLUTTER_NOTIFICATION_CLICK",
          "resource_id" => "#{n.record_id}"
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
