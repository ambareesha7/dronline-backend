defmodule Calls.Specialists do
  alias Calls.Call

  import Mockery.Macro

  defmacrop call_notification do
    quote do
      mockable(PushNotifications.Call, by: PushNotifications.CallMock)
    end
  end

  defmacrop opentok do
    quote do: mockable(OpenTok, by: OpenTokMock)
  end

  defmodule SpecialistPatientCall do
    defstruct [
      :specialist_id,
      :patient_id,
      :call_id,
      :session_id,
      :specialist_session_token,
      :api_key
    ]
  end

  def call_patient(specialist_id, patient_id) do
    {:ok, session_id} = opentok().create_session()

    call = %SpecialistPatientCall{
      specialist_id: specialist_id,
      patient_id: patient_id,
      call_id: Call.start(),
      session_id: session_id,
      specialist_session_token: OpenTok.generate_session_token(session_id),
      api_key: api_key()
    }

    :ok = notify_patient!(call)

    call
  end

  defp notify_patient!(call) do
    patient_session_token = OpenTok.generate_session_token(call.session_id)

    call_notification().send(%PushNotifications.Call.SpecialistCallToPatient{
      api_key: api_key(),
      call_id: call.call_id,
      patient_session_token: patient_session_token,
      send_to_patient_id: PatientProfilesManagement.who_should_be_notified(call.patient_id),
      session_id: call.session_id,
      start_time: :os.system_time(:second),
      specialist_id: call.specialist_id
    })

    :ok
  end

  defp api_key, do: Application.get_env(:opentok, :api_key)
end
