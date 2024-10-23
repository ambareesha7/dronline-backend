defmodule Calls.SpecialistsTest do
  use Postgres.DataCase, async: true

  import Mockery.Assertions

  alias Calls.Specialists

  describe "calling the patient" do
    test "returns a session_id and session_token" do
      specialist_id = 1
      patient_id = 10

      call = Specialists.call_patient(specialist_id, patient_id)

      assert call.session_id
      assert call.specialist_session_token
      assert call.call_id
    end

    test "sends notification to the patient" do
      specialist_id = 1
      patient_id = 10

      _call = Specialists.call_patient(specialist_id, patient_id)

      assert_called(PushNotifications.Call, :send)
    end
  end
end
