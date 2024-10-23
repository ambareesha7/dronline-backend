defmodule Calls.PendingVisitTest do
  use Postgres.DataCase, async: true

  import Mockery.Assertions

  describe "call_patient/1" do
    test "returns a session_id and session_token" do
      patient_id = 1
      record_id = 10

      call = Calls.PendingVisit.call_patient(patient_id, record_id)

      assert call.session_id
      assert call.gp_session_token
      assert call.call_id
    end

    test "sends notification to the patient" do
      patient_id = 1
      record_id = 10

      _call = Calls.PendingVisit.call_patient(patient_id, record_id)

      assert_called(PushNotifications.Call, :send)
    end
  end
end
