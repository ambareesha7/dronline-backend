defmodule PushNotifications.Call.PendingVisitCall do
  @behaviour PushNotifications.Call

  @fields [
    :api_key,
    :call_id,
    :patient_session_token,
    :send_to_patient_id,
    :session_id,
    :start_time
  ]

  @enforce_keys @fields
  defstruct @fields

  @impl true
  def get_firebase_device_tokens(%__MODULE__{} = n) do
    PushNotifications.Devices.PatientDevice.all_tokens_for_patient_id(n.send_to_patient_id)
  end

  @impl true
  def get_ios_device_tokens(%__MODULE__{} = n) do
    PushNotifications.Devices.PatientIOSDevice.all_tokens_for_patient_id(n.send_to_patient_id)
  end

  @impl true
  def prepare_firebase_body(%__MODULE__{} = n, device_token) do
    %{
      "message" => %{
        "token" => device_token,
        "data" => %{
          "action" => "start_pending_visit_call",
          "api_key" => n.api_key,
          "call_id" => n.call_id,
          "patient_session_token" => n.patient_session_token,
          "session_id" => n.session_id,
          "timestamp" => "#{n.start_time}"
        },
        "android" => %{
          "priority" => "high"
        }
      }
    }
  end

  @impl true
  def prepare_ios_body(%__MODULE__{} = n) do
    %{
      "aps" => %{
        "sound" => "notification_ring.caf"
      },
      "action" => "start_pending_visit_call",
      "call_id" => n.call_id,
      "session_id" => n.session_id,
      "patient_session_token" => n.patient_session_token,
      "api_key" => n.api_key,
      "timestamp" => "#{n.start_time}"
    }
  end
end
