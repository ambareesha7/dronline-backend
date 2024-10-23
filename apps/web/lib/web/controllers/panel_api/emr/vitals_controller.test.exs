defmodule Web.PanelApi.EMR.VitalsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.CreateNewVitalsRequest
  alias Proto.EMR.CreateNewVitalsResponse
  alias Proto.EMR.GetVitalsHistoryResponse
  alias Proto.EMR.GetVitalsResponse

  alias Proto.EMR.VitalsParams

  describe "POST create" do
    setup [:authenticate_nurse, :proto_content]

    test "creates vitals and returns associated data", %{conn: conn, current_nurse: current_nurse} do
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_nurse.id)

      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:manual_record, patient_id: patient.id)

      proto =
        %CreateNewVitalsRequest{
          vitals_params: %VitalsParams{
            height: %Proto.Generics.Height{value: 170},
            weight: %Proto.Generics.Weight{value: 80},
            blood_pressure_systolic: 101,
            blood_pressure_diastolic: 102,
            pulse: 103,
            respiratory_rate: 104,
            body_temperature: 36.6,
            physical_exam: "Physical exam"
          }
        }
        |> CreateNewVitalsRequest.encode()

      conn = post(conn, panel_emr_vitals_path(conn, :create, patient, record), proto)

      assert %CreateNewVitalsResponse{
               vitals: %Proto.EMR.Vitals{} = returned_vitals,
               specialists: [%Proto.Generics.Specialist{id: returned_specialist_id}]
             } = proto_response(conn, 200, CreateNewVitalsResponse)

      assert returned_vitals.record_id == record.id
      assert returned_vitals.height.value == 170
      assert returned_vitals.weight.value == 80
      assert returned_vitals.blood_pressure_systolic == 101
      assert returned_vitals.blood_pressure_diastolic == 102
      assert returned_vitals.pulse == 103
      assert returned_vitals.respiratory_rate == 104
      assert returned_vitals.physical_exam == "Physical exam"
      assert Float.round(returned_vitals.body_temperature, 1) == 36.6

      assert returned_specialist_id == current_nurse.id
    end
  end

  describe "GET show" do
    setup [:authenticate_nurse]

    test "returns empty vitals if patient don't have any provided yet", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      conn = get(conn, panel_emr_vitals_path(conn, :show, patient))

      assert %GetVitalsResponse{vitals: nil, specialists: []} =
               proto_response(conn, 200, GetVitalsResponse)
    end

    test "returns latest vitals and associated data", %{conn: conn, current_nurse: current_nurse} do
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_nurse.id)

      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:manual_record, patient_id: patient.id)

      _vitals =
        EMR.Factory.insert(:vitals,
          patient_id: patient.id,
          record_id: record.id,
          nurse_id: current_nurse.id
        )

      conn = get(conn, panel_emr_vitals_path(conn, :show, patient))

      assert %GetVitalsResponse{
               vitals: %Proto.EMR.Vitals{} = returned_vitals,
               specialists: [%Proto.Generics.Specialist{id: returned_specialist_id}]
             } = proto_response(conn, 200, GetVitalsResponse)

      assert returned_vitals.record_id == record.id
      assert returned_specialist_id == current_nurse.id
    end
  end

  describe "GET history" do
    setup [:authenticate_nurse]

    test "returns vitals history and associated data", %{conn: conn, current_nurse: current_nurse} do
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_nurse.id)

      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:manual_record, patient_id: patient.id)

      _vitals =
        EMR.Factory.insert(:vitals,
          patient_id: patient.id,
          record_id: record.id,
          nurse_id: current_nurse.id
        )

      conn = get(conn, panel_emr_vitals_path(conn, :history, patient))

      assert %GetVitalsHistoryResponse{
               vitals_history: [%Proto.EMR.Vitals{} = returned_vitals],
               specialists: [%Proto.Generics.Specialist{id: returned_specialist_id}],
               next_token: ""
             } = proto_response(conn, 200, GetVitalsHistoryResponse)

      assert returned_vitals.record_id == record.id
      assert returned_specialist_id == current_nurse.id
    end

    test "returns next_token when there's more entries", %{
      conn: conn,
      current_nurse: current_nurse
    } do
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_nurse.id)

      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:manual_record, patient_id: patient.id)

      vitals =
        EMR.Factory.insert(:vitals,
          patient_id: patient.id,
          record_id: record.id,
          nurse_id: current_nurse.id
        )

      params = %{"limit" => "0"}
      conn = get(conn, panel_emr_vitals_path(conn, :history, patient), params)

      assert %GetVitalsHistoryResponse{
               vitals_history: [],
               specialists: [],
               next_token: next_token
             } = proto_response(conn, 200, GetVitalsHistoryResponse)

      assert next_token == NaiveDateTime.to_iso8601(vitals.inserted_at)
    end
  end
end
