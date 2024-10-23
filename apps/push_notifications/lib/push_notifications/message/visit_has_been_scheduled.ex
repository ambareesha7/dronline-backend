defmodule PushNotifications.Message.VisitHasBeenScheduled do
  @behaviour PushNotifications.Message

  @fields [
    :patient_id,
    :patient_first_name,
    :patient_last_name,
    :record_id,
    :specialist_id,
    :visit_start_time
  ]

  @enforce_keys @fields
  defstruct @fields

  @impl true
  def get_device_tokens(%__MODULE__{} = n) do
    PushNotifications.Devices.SpecialistDevice.all_tokens_for_specialist_id(n.specialist_id)
  end

  @impl true
  def prepare_body(%__MODULE__{} = n, device_token) do
    %{
      "message" => %{
        "token" => device_token,
        "notification" => %{
          "title" => "DrOnline",
          "body" =>
            "New visit has been scheduled with #{n.patient_first_name} #{n.patient_last_name}"
        },
        "data" => %{
          "action" => "visit_has_been_scheduled",
          "click_action" => "FLUTTER_NOTIFICATION_CLICK",
          "patient_id" => to_string(n.patient_id),
          "record_id" => to_string(n.record_id),
          "start_time" => to_string(n.visit_start_time)
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
