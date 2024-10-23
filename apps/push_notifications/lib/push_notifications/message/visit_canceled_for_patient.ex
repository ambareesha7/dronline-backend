defmodule PushNotifications.Message.VisitCanceledForPatient do
  @behaviour PushNotifications.Message

  @fields [
    :specialist_title,
    :specialist_first_name,
    :specialist_last_name,
    :patient_id,
    :record_id,
    :specialist_id,
    :visit_start_time,
    :is_refunded
  ]

  @enforce_keys @fields
  defstruct @fields

  @impl true
  def get_device_tokens(%__MODULE__{} = n) do
    PushNotifications.Devices.PatientDevice.all_tokens_for_patient_id(n.patient_id)
  end

  @impl true
  def prepare_body(%__MODULE__{} = n, device_token) do
    notification_body =
      if n.is_refunded do
        "Visit with #{n.specialist_title} #{n.specialist_first_name} #{n.specialist_last_name} has been canceled by specialist, your payment will be refunded"
      else
        "Visit with #{n.specialist_title} #{n.specialist_first_name} #{n.specialist_last_name} has been canceled by specialist"
      end

    %{
      "message" => %{
        "token" => device_token,
        "notification" => %{
          "title" => "DrOnline",
          "body" => notification_body
        },
        "data" => %{
          "action" => "visit_has_been_canceled",
          "click_action" => "FLUTTER_NOTIFICATION_CLICK",
          "patient_id" => to_string(n.patient_id),
          "record_id" => to_string(n.record_id),
          "start_time" => to_string(n.visit_start_time),
          "is_refunded" => to_string(n.is_refunded)
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
