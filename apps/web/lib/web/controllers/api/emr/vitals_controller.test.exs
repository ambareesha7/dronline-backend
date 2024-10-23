defmodule Web.Api.EMR.VitalsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.GetVitalsHistoryResponse
  alias Proto.EMR.GetVitalsResponse

  describe "GET show" do
    setup [:authenticate_patient]

    test "returns empty vitals if patient don't have any provided yet", %{conn: conn} do
      conn = get(conn, emr_vitals_path(conn, :show))

      assert %GetVitalsResponse{vitals: nil, specialists: []} =
               proto_response(conn, 200, GetVitalsResponse)
    end

    test "returns latest vitals and associated data", %{
      conn: conn,
      current_patient: current_patient
    } do
      nurse = Authentication.Factory.insert(:specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: nurse.id)

      record = EMR.Factory.insert(:manual_record, patient_id: current_patient.id)

      _vitals =
        EMR.Factory.insert(:vitals,
          patient_id: current_patient.id,
          record_id: record.id,
          nurse_id: nurse.id
        )

      conn = get(conn, emr_vitals_path(conn, :show))

      assert %GetVitalsResponse{
               vitals: %Proto.EMR.Vitals{} = returned_vitals,
               specialists: [%Proto.Generics.Specialist{id: returned_specialist_id}]
             } = proto_response(conn, 200, GetVitalsResponse)

      assert returned_vitals.record_id == record.id
      assert returned_specialist_id == nurse.id
    end
  end

  describe "GET history" do
    setup [:authenticate_patient]

    test "returns vitals history and associated data", %{
      conn: conn,
      current_patient: current_patient
    } do
      nurse = Authentication.Factory.insert(:specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: nurse.id)

      record = EMR.Factory.insert(:manual_record, patient_id: current_patient.id)

      _vitals =
        EMR.Factory.insert(:vitals,
          patient_id: current_patient.id,
          record_id: record.id,
          nurse_id: nurse.id
        )

      conn = get(conn, emr_vitals_path(conn, :history))

      assert %GetVitalsHistoryResponse{
               vitals_history: [%Proto.EMR.Vitals{} = returned_vitals],
               specialists: [%Proto.Generics.Specialist{id: returned_specialist_id}],
               next_token: ""
             } = proto_response(conn, 200, GetVitalsHistoryResponse)

      assert returned_vitals.record_id == record.id
      assert returned_specialist_id == nurse.id
    end

    test "returns next_token when there's more entries", %{
      conn: conn,
      current_patient: current_patient
    } do
      nurse = Authentication.Factory.insert(:specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: nurse.id)

      record = EMR.Factory.insert(:manual_record, patient_id: current_patient.id)

      vitals =
        EMR.Factory.insert(:vitals,
          patient_id: current_patient.id,
          record_id: record.id,
          nurse_id: nurse.id
        )

      params = %{"limit" => "0"}
      conn = get(conn, emr_vitals_path(conn, :history), params)

      assert %GetVitalsHistoryResponse{
               vitals_history: [],
               specialists: [],
               next_token: next_token
             } = proto_response(conn, 200, GetVitalsHistoryResponse)

      assert next_token == NaiveDateTime.to_iso8601(vitals.inserted_at)
    end
  end

  describe "GET history_for_record" do
    setup [:authenticate_patient]

    test "returns vitals history and associated data", %{
      conn: conn,
      current_patient: current_patient
    } do
      nurse = Authentication.Factory.insert(:specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: nurse.id)

      record = EMR.Factory.insert(:manual_record, patient_id: current_patient.id)

      _vitals =
        EMR.Factory.insert(:vitals,
          patient_id: current_patient.id,
          record_id: record.id,
          nurse_id: nurse.id
        )

      conn = get(conn, emr_vitals_path(conn, :history_for_record, record))

      assert %GetVitalsHistoryResponse{
               vitals_history: [%Proto.EMR.Vitals{} = returned_vitals],
               specialists: [%Proto.Generics.Specialist{id: returned_specialist_id}],
               next_token: ""
             } = proto_response(conn, 200, GetVitalsHistoryResponse)

      assert returned_vitals.record_id == record.id
      assert returned_specialist_id == nurse.id
    end

    test "returns next_token when there's more entries", %{
      conn: conn,
      current_patient: current_patient
    } do
      nurse = Authentication.Factory.insert(:specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: nurse.id)

      record = EMR.Factory.insert(:manual_record, patient_id: current_patient.id)

      vitals =
        EMR.Factory.insert(:vitals,
          patient_id: current_patient.id,
          record_id: record.id,
          nurse_id: nurse.id
        )

      params = %{"limit" => "0"}
      conn = get(conn, emr_vitals_path(conn, :history_for_record, record), params)

      assert %GetVitalsHistoryResponse{
               vitals_history: [],
               specialists: [],
               next_token: next_token
             } = proto_response(conn, 200, GetVitalsHistoryResponse)

      assert next_token == NaiveDateTime.to_iso8601(vitals.inserted_at)
    end
  end
end
