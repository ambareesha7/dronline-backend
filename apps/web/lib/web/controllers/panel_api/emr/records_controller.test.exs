defmodule Web.PanelApi.EMR.RecordsControllerTest do
  use Web.ConnCase, async: true
  import Mockery

  alias Proto.EMR.GetPatientRecordResponse
  alias Proto.EMR.GetPatientRecordsResponse

  alias Proto.EMR.PatientRecord

  describe "POST create" do
    setup [:authenticate_nurse]

    test "creates record and returns it with related data", %{
      conn: conn,
      current_nurse: current_nurse
    } do
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_nurse.id)

      patient = PatientProfile.Factory.insert(:patient)

      conn = post(conn, panel_emr_records_path(conn, :create, patient))

      assert %GetPatientRecordResponse{
               patient_record: %PatientRecord{
                 type:
                   {:manually,
                    %PatientRecord.Manually{created_by_specialist_id: created_by_specialist_id}}
               },
               specialists: [
                 %Proto.Generics.Specialist{} = returned_specialist
               ]
             } = proto_response(conn, 200, GetPatientRecordResponse)

      assert created_by_specialist_id == current_nurse.id
      assert returned_specialist.id == current_nurse.id
    end
  end

  describe "GET index" do
    setup [:authenticate_nurse]

    test "returns records with related data", %{conn: conn, current_nurse: current_nurse} do
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_nurse.id)

      patient = PatientProfile.Factory.insert(:patient)

      _manual_record =
        EMR.Factory.insert(:manual_record,
          patient_id: patient.id,
          created_by_specialist_id: current_nurse.id
        )

      _call_record =
        EMR.Factory.insert(:call_record,
          patient_id: patient.id,
          specialist_id: current_nurse.id,
          call_session_id: "call_session_id"
        )

      conn = get(conn, panel_emr_records_path(conn, :index, patient))

      %GetPatientRecordsResponse{
        patient_records: [
          %PatientRecord{
            type: {:call, %PatientRecord.Call{with_specialist_id: record_specialist_id}}
          },
          %PatientRecord{
            type:
              {:manually, %PatientRecord.Manually{created_by_specialist_id: record_specialist_id}}
          }
        ],
        next_token: "",
        specialists: [
          %Proto.Generics.Specialist{} = returned_specialist
        ]
      } = proto_response(conn, 200, GetPatientRecordsResponse)

      assert returned_specialist.id == current_nurse.id
    end
  end

  describe "GET show" do
    setup [:authenticate_nurse]

    test "returns record with related data", %{conn: conn, current_nurse: current_nurse} do
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_nurse.id)

      patient = PatientProfile.Factory.insert(:patient)

      record =
        EMR.Factory.insert(:manual_record,
          patient_id: patient.id,
          created_by_specialist_id: current_nurse.id
        )

      conn = get(conn, panel_emr_records_path(conn, :show, patient, record))

      %GetPatientRecordResponse{
        patient_record:
          %PatientRecord{
            type:
              {:manually,
               %PatientRecord.Manually{created_by_specialist_id: created_by_specialist_id}}
          } = returned_record,
        specialists: [
          %Proto.Generics.Specialist{} = returned_specialist
        ]
      } = proto_response(conn, 200, GetPatientRecordResponse)

      assert returned_record.record_id == record.id
      assert created_by_specialist_id == current_nurse.id
      assert returned_specialist.id == current_nurse.id
    end
  end

  describe "POST close" do
    setup [:authenticate_nurse]

    test "succeeds", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      conn = post(conn, panel_emr_records_path(conn, :close, patient, timeline))

      assert response(conn, 204)
    end
  end

  describe "GET pdf" do
    setup [:authenticate_nurse]

    test "returns 404 when given record doesn't exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      record_id = 0

      conn = get(conn, panel_emr_records_path(conn, :pdf, patient, record_id))
      assert response(conn, 404)
    end

    test "returns pdf binary data for valid records", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      mock(EMR, [generate_record_pdf_for_specialist: 3], {:ok, :erlang.term_to_binary(:mock)})

      conn = get(conn, panel_emr_records_path(conn, :pdf, patient, record))

      assert conn.status == 200
      assert conn.resp_body |> is_binary()
      assert {"content-type", "application/pdf; charset=utf-8"} in conn.resp_headers
    end
  end
end
