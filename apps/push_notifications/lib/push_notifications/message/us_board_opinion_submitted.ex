defmodule PushNotifications.Message.USBoardOpinionSubmitted do
  @behaviour PushNotifications.Message

  @fields [
    :send_to_patient_id,
    :us_board_request_id
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
          "title" => "Specialist submitted your second opinion!",
          "body" => "Check your second opinion"
        },
        "data" => %{
          "action" => "specialist_submitted_second_opinion",
          "click_action" => "FLUTTER_NOTIFICATION_CLICK",
          "us_board_request_id" => n.us_board_request_id
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
