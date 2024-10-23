defmodule Calls.DoctorPendingVisit do
  import Mockery.Macro

  defmacrop call_notification do
    quote do
      mockable(PushNotifications.Call, by: PushNotifications.CallMock)
    end
  end

  defmacrop opentok do
    quote do: mockable(OpenTok, by: OpenTokMock)
  end

  defmodule DoctorPendingVisitCall do
    defstruct [
      :api_key,
      :call_id,
      :doctor_id,
      :doctor_session_token,
      :patient_id,
      :session_id
    ]
  end

  def call_patient(doctor_id, patient_id, record_id) do
    {:ok, session_id} = opentok().create_session(record_id)

    call = %DoctorPendingVisitCall{
      api_key: api_key(),
      call_id: Calls.Call.start(),
      doctor_id: doctor_id,
      doctor_session_token: OpenTok.generate_session_token(session_id),
      patient_id: patient_id,
      session_id: session_id
    }

    :ok = notify_patient(call)

    call
  end

  defp notify_patient(call) do
    patient_session_token = OpenTok.generate_session_token(call.session_id)
    {:ok, basic_info} = SpecialistProfile.fetch_basic_info(call.doctor_id)

    call_notification().send(%PushNotifications.Call.VisitCall{
      api_key: api_key(),
      call_id: call.call_id,
      doctor_avatar_url: basic_info.image_url,
      doctor_id: call.doctor_id,
      doctor_first_name: basic_info.first_name,
      doctor_last_name: basic_info.last_name,
      patient_session_token: patient_session_token,
      send_to_patient_id: PatientProfilesManagement.who_should_be_notified(call.patient_id),
      session_id: call.session_id,
      start_time: :os.system_time(:second)
    })

    :ok
  end

  defp api_key, do: Application.get_env(:opentok, :api_key)
end
