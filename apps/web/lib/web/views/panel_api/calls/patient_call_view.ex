defmodule Web.PanelApi.Calls.PatientCallView do
  use Web, :view

  def render("nurse_patient_call.proto", %{call: call}) do
    %{
      patient_id: call.patient_id,
      session_id: call.session_id,
      nurse_session_token: call.nurse_session_token,
      call_id: call.call_id,
      api_key: call.api_key
    }
    |> Proto.validate!(Proto.Calls.NursePatientCallResponse)
    |> Proto.Calls.NursePatientCallResponse.new()
  end

  def render("specialist_patient_call.proto", %{call: call, record: record}) do
    %{
      patient_id: call.patient_id,
      session_id: call.session_id,
      specialist_session_token: call.specialist_session_token,
      call_id: call.call_id,
      api_key: call.api_key,
      record_id: record.id
    }
    |> Proto.validate!(Proto.Calls.SpecialistPatientCallResponse)
    |> Proto.Calls.SpecialistPatientCallResponse.new()
  end
end
