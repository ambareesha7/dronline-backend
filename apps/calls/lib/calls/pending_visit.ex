defmodule Calls.PendingVisit do
  import Mockery.Macro

  defmacrop call_notification do
    quote do
      mockable(PushNotifications.Call, by: PushNotifications.CallMock)
    end
  end

  defmacrop opentok do
    quote do: mockable(OpenTok, by: OpenTokMock)
  end

  defmodule PendingVisitCall do
    defstruct [
      :api_key,
      :call_id,
      :gp_session_token,
      :patient_id,
      :session_id
    ]
  end

  def call_patient(patient_id, record_id) do
    {:ok, session_id} = opentok().create_session(record_id)

    call = %PendingVisitCall{
      api_key: api_key(),
      call_id: Calls.Call.start(),
      gp_session_token: OpenTok.generate_session_token(session_id),
      patient_id: patient_id,
      session_id: session_id
    }

    :ok = notify_patient(call)

    call
  end

  defp notify_patient(call) do
    patient_session_token = OpenTok.generate_session_token(call.session_id)

    call_notification().send(%PushNotifications.Call.PendingVisitCall{
      api_key: api_key(),
      call_id: call.call_id,
      patient_session_token: patient_session_token,
      send_to_patient_id: PatientProfilesManagement.who_should_be_notified(call.patient_id),
      session_id: call.session_id,
      start_time: :os.system_time(:second)
    })

    :ok
  end

  defp api_key, do: Application.get_env(:opentok, :api_key)
end
