defmodule Web.Api.EMR.ResultsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.GetRecordBloodPressureEntriesResponse
  alias Proto.EMR.GetRecordBMIEntriesResponse

  describe "GET blood_pressure_entries" do
    setup [:authenticate_patient]

    test "succeeds", %{conn: conn, current_patient: current_patient} do
      specialist = Authentication.Factory.insert(:verified_specialist)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)

      params = %{
        weight: 183,
        height: 80,
        systolic: 120,
        diastolic: 60,
        pulse: 80,
        ekg_file_url: "http://example.com/ekg.png"
      }

      {:ok, vitals} = Triage.Vitals.create(current_patient.id, timeline.id, specialist.id, params)

      conn = get(conn, emr_results_path(conn, :blood_pressure_entries, timeline.id))

      assert %GetRecordBloodPressureEntriesResponse{
               blood_pressure_entries: [entry],
               next_token: ""
             } = proto_response(conn, 200, GetRecordBloodPressureEntriesResponse)

      assert entry.blood_pressure.systolic == 120
      assert entry.blood_pressure.diastolic == 60
      assert entry.blood_pressure.pulse == 80
      assert entry.inserted_at == Timex.to_unix(vitals.inserted_at)
    end
  end

  describe "GET bmi_entries" do
    setup [:authenticate_patient]

    test "succeeds", %{conn: conn, current_patient: current_patient} do
      specialist = Authentication.Factory.insert(:verified_specialist)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)

      params = %{
        weight: 183,
        height: 80,
        systolic: 120,
        diastolic: 60,
        pulse: 80,
        ekg_file_url: "http://example.com/ekg.png"
      }

      {:ok, vitals} = Triage.Vitals.create(current_patient.id, timeline.id, specialist.id, params)

      conn = get(conn, emr_results_path(conn, :bmi_entries, timeline.id))

      assert %GetRecordBMIEntriesResponse{
               bmi_entries: [entry],
               next_token: ""
             } = proto_response(conn, 200, GetRecordBMIEntriesResponse)

      assert entry.bmi.weight.value == 183
      assert entry.bmi.height.value == 80
      assert entry.inserted_at == Timex.to_unix(vitals.inserted_at)
    end
  end
end
