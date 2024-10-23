defmodule Web.PanelApi.Calls.PatientCallControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Calls.NursePatientCallRequest
  alias Proto.Calls.NursePatientCallResponse
  alias Proto.Calls.SpecialistPatientCallRequest
  alias Proto.Calls.SpecialistPatientCallResponse

  describe "calling the patient as Nurse" do
    setup [:authenticate_nurse, :proto_content, :accept_proto]

    test "returns necessary info to the client", %{conn: conn} do
      request =
        %NursePatientCallRequest{
          patient_id: 1
        }
        |> NursePatientCallRequest.encode()

      resp = post(conn, panel_calls_patient_call_path(conn, :create), request)

      %NursePatientCallResponse{
        patient_id: 1,
        call_id: _,
        session_id: _,
        nurse_session_token: _,
        api_key: _
      } = proto_response(resp, 200, NursePatientCallResponse)
    end
  end

  describe "calling the patient as Specialist" do
    setup [:authenticate_external, :proto_content, :accept_proto]

    test "returns necessary info to the client", %{conn: conn} do
      request =
        %SpecialistPatientCallRequest{
          patient_id: 1
        }
        |> SpecialistPatientCallRequest.encode()

      resp = post(conn, panel_calls_patient_call_path(conn, :create_for_specialist), request)

      %SpecialistPatientCallResponse{
        patient_id: 1,
        call_id: _,
        session_id: _,
        specialist_session_token: _,
        api_key: _,
        record_id: _
      } = proto_response(resp, 200, SpecialistPatientCallResponse)
    end
  end
end
