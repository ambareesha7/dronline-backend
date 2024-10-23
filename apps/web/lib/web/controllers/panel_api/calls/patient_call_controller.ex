defmodule Web.PanelApi.Calls.PatientCallController do
  use Conductor
  use Web, :controller

  action_fallback(Web.FallbackController)

  @authorize scope: "NURSE"
  @decode Proto.Calls.NursePatientCallRequest
  def create(conn, _params) do
    nurse_id = conn.assigns.current_specialist_id
    patient_id = conn.assigns.protobuf.patient_id
    record_id = conn.assigns.protobuf.record_id

    call = Calls.Nurses.call_patient(nurse_id, patient_id, record_id)

    render(conn, "nurse_patient_call.proto", %{call: call})
  end

  @authorize scopes: ["GP", "EXTERNAL"]
  @decode Proto.Calls.SpecialistPatientCallRequest
  def create_for_specialist(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    patient_id = conn.assigns.protobuf.patient_id

    call = Calls.Specialists.call_patient(specialist_id, patient_id)

    {:ok, record} =
      EMR.create_call_type_patient_record(patient_id, specialist_id, call.session_id)

    render(conn, "specialist_patient_call.proto", %{call: call, record: record})
  end
end
