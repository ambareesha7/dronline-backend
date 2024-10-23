defmodule PushNotifications.Call.SpecialistCallToPatient do
  @behaviour PushNotifications.Call

  @fields [
    :api_key,
    :call_id,
    :patient_session_token,
    :send_to_patient_id,
    :session_id,
    :start_time,
    :specialist_id
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
          "action" => "start_call_with_specialist",
          "call_id" => n.call_id,
          "session_id" => n.session_id,
          "patient_session_token" => n.patient_session_token,
          "api_key" => n.api_key,
          "timestamp" => "#{n.start_time}",
          "specialist_id" => Integer.to_string(n.specialist_id)
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
      "action" => "start_call_with_specialist",
      "call_id" => n.call_id,
      "session_id" => n.session_id,
      "patient_session_token" => n.patient_session_token,
      "api_key" => n.api_key,
      "timestamp" => "#{n.start_time}",
      "specialist_id" => Integer.to_string(n.specialist_id)
    }
  end
end
