defmodule Web.Api.EMR.CallRecordingsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.GetRecordCallRecordingsResponse

  describe "GET index" do
    setup [:authenticate_patient]

    test "returns list of call recordings", %{conn: conn, current_patient: current_patient} do
      record = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)

      cmd = %EMR.PatientRecords.Timeline.Commands.CreateCallRecordingItem{
        patient_id: current_patient.id,
        record_id: record.id,
        session_id: "SESSION",
        thumbnail_gcs_path: "THUMBNAIL",
        video_s3_path: "VIDEO",
        created_at: 1_596_458_061,
        duration: 60
      }

      {:ok, _timeline_item} = EMR.create_call_recording_timeline_item(cmd)

      conn = get(conn, emr_call_recordings_path(conn, :index, record.id))

      assert %GetRecordCallRecordingsResponse{call_recordings: [fetched], next_token: ""} =
               proto_response(conn, 200, GetRecordCallRecordingsResponse)

      assert fetched.session_id == "SESSION"
      assert fetched.thumbnail_url =~ "THUMBNAIL"
      assert fetched.video_url =~ "VIDEO"
    end
  end
end
