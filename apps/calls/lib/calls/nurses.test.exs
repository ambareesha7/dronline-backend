defmodule Calls.NursesTest do
  use Postgres.DataCase, async: true

  import Mockery.Assertions

  alias Calls.Nurses

  describe "calling the patient" do
    test "returns a session_id and session_token" do
      nurse_id = 1
      patient_id = 10
      record_id = 20

      call = Nurses.call_patient(nurse_id, patient_id, record_id)

      assert call.session_id
      assert call.nurse_session_token
      assert call.call_id
    end

    test "sends notification to the patient" do
      nurse_id = 1
      patient_id = 10
      record_id = 20

      _call = Nurses.call_patient(nurse_id, patient_id, record_id)

      assert_called(PushNotifications.Call, :send)
    end
  end
end
