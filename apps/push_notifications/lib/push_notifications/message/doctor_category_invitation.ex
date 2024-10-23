defmodule PushNotifications.Message.DoctorCategoryInvitation do
  @behaviour PushNotifications.Message

  @fields [:specialist_ids]

  @enforce_keys @fields
  defstruct @fields

  @impl true
  def get_device_tokens(%__MODULE__{} = n) do
    PushNotifications.Devices.SpecialistDevice.all_tokens_for_specialist_ids(n.specialist_ids)
  end

  @impl true
  def prepare_body(%__MODULE__{} = _n, device_token) do
    %{
      "message" => %{
        "token" => device_token,
        "notification" => %{
          "title" => "DrOnline",
          "body" => "New call invitation has appeared for your medical category"
        },
        "data" => %{
          "action" => "doctor_category_invitation",
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
