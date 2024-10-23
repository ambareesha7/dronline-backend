defmodule PushNotifications.Message.VisitDemandCategoryProvided do
  @behaviour PushNotifications.Message

  @fields [
    :medical_category_id,
    :send_to_patient_id,
    :medical_category_name
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
          "title" => "New slots for #{n.medical_category_name}!",
          "body" => "Book visit now"
        },
        "data" => %{
          "action" => "visit_demand_category",
          "click_action" => "FLUTTER_NOTIFICATION_CLICK",
          "medical_category_id" => "#{n.medical_category_id}",
          "medical_category_name" => "#{n.medical_category_name}"
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
