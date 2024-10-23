defmodule Calls.DoctorPendingVisitTest do
  use Postgres.DataCase, async: true

  import Mockery.Assertions

  describe "call_patient/2" do
    test "returns a session_id and session_token" do
      doctor_id = 1
      patient_id = 10
      record_id = 20

      call = Calls.DoctorPendingVisit.call_patient(doctor_id, patient_id, record_id)

      assert call.session_id
      assert call.doctor_session_token
      assert call.call_id
    end

    test "sends notification to the patient" do
      doctor_id = 1
      patient_id = 10
      record_id = 20

      _call = Calls.DoctorPendingVisit.call_patient(doctor_id, patient_id, record_id)

      assert_called(PushNotifications.Call, :send)
    end
  end
end
