defmodule PushNotifications.Message.TriageUnitDispatched do
  @behaviour PushNotifications.Message

  @fields [:record_id, :send_to_patient_id]

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
        "data" => %{
          "action" => "dispatch_send",
          "resource_id" => "#{n.record_id}",
          "click_action" => "FLUTTER_NOTIFICATION_CLICK"
        },
        "notification" => %{
          "title" => "DrOnline",
          "body" => "Triage Unit has been dispatched"
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
