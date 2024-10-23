defmodule PushNotifications.Message.VisitDemandSpecialistProvided do
  @behaviour PushNotifications.Message

  @fields [
    :send_to_patient_id,
    :specialist_name,
    :specialist_id
  ]

  @enforce_keys @fields
  defstruct @fields

  @impl true
  def get_device_tokens(%__MODULE__{} = n) do
    PushNotifications.Devices.PatientDevice.all_tokens_for_patient_id(n.send_to_patient_id)
  end

  @impl true
  def prepare_body(%__MODULE__{} = n, device_token) do
    %{
      "message" => %{
        "token" => device_token,
        "notification" => %{
          "title" => "#{n.specialist_name} has new slots!",
          "body" => "Book a visit"
        },
        "data" => %{
          "action" => "visit_demand_specialist",
          "click_action" => "FLUTTER_NOTIFICATION_CLICK",
          "specialist_id" => "#{n.specialist_id}"
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
