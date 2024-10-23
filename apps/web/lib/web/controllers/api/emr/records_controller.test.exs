defmodule Web.Api.EMR.RecordsControllerTest do
  use Web.ConnCase, async: true

  import Mockery

  alias Proto.EMR.GetPatientRecordResponse
  alias Proto.EMR.GetPatientRecordsResponse

  alias Proto.EMR.PatientRecord

  describe "GET index" do
    setup [:authenticate_patient]

    test "returns records with related data", %{conn: conn, current_patient: current_patient} do
      doctor = Authentication.Factory.insert(:specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: doctor.id)

      record =
        EMR.Factory.insert(:manual_record,
          patient_id: current_patient.id,
          created_by_specialist_id: doctor.id
        )

      conn = get(conn, emr_records_path(conn, :index))

      %GetPatientRecordsResponse{
        patient_records: [
          %PatientRecord{
            type:
              {:manually,
               %PatientRecord.Manually{created_by_specialist_id: created_by_specialist_id}}
          } = returned_record
        ],
        next_token: "",
        specialists: [
          %Proto.Generics.Specialist{} = returned_specialist
        ]
      } = proto_response(conn, 200, GetPatientRecordsResponse)

      assert returned_record.record_id == record.id
      assert created_by_specialist_id == doctor.id
      assert returned_specialist.id == doctor.id
    end
  end

  describe "GET show" do
    setup [:authenticate_patient]

    test "returns record with related data", %{conn: conn, current_patient: current_patient} do
      doctor = Authentication.Factory.insert(:specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: doctor.id)

      record =
        EMR.Factory.insert(:manual_record,
          patient_id: current_patient.id,
          created_by_specialist_id: doctor.id
        )

      conn = get(conn, emr_records_path(conn, :show, record))

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
      assert created_by_specialist_id == doctor.id
      assert returned_specialist.id == doctor.id
    end
  end

  describe "GET pdf" do
    setup [:authenticate_patient]

    test "returns 404 when given record doesn't exist", %{conn: conn} do
      record_id = 0

      conn = get(conn, emr_records_path(conn, :pdf, record_id))
      assert response(conn, 404)
    end

    test "returns pdf binary data for valid records", %{conn: conn, current_patient: patient} do
      record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      mock(EMR, [generate_record_pdf_for_patient: 2], {:ok, :erlang.term_to_binary(:mock)})

      conn = get(conn, emr_records_path(conn, :pdf, record))

      assert conn.status == 200
      assert conn.resp_body |> is_binary()
      assert {"content-type", "application/pdf; charset=utf-8"} in conn.resp_headers
    end
  end
end
