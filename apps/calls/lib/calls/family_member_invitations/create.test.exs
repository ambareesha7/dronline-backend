defmodule Calls.FamilyMemberInvitationsTest do
  use Postgres.DataCase, async: true

  import Mockery.Assertions

  alias Calls.FamilyMemberInvitation
  alias Calls.FamilyMemberInvitations.Create

  describe "call/1" do
    test "inserts invitations into database, sends SMS" do
      params = %{
        call_id: "call_id",
        session_id:
          "T1==cGFydG5lcl9pZD00NjI4MTExMiZzaWc9MjZDRThCQjA4MzgxM0M1QTI4QkU0ODlGM0M5Rjk0NDk2NkFBMjBGMDpjcmVhdGVfdGltZT0xNjA3MzYyNjMzJmV4cGlyZV90aW1lPTE2MDc0NDkwMzMmbm9uY2U9OThENEQ4QkFGQzlGOTZDRjUwOUMzQ0RCNEU1NEFFM0Imcm9sZT1wdWJsaXNoZXImc2Vzc2lvbl9pZD0xX01YNDBOakk0TVRFeE1uNS1NVFl3TnpNMk1qWXpNelkyTUg1c1ExWlRhMlZTWjBWaWVFUnplR3hMVmtoRVRuWjJjQzktUVg0",
        phone_number: "+38012345678",
        name: "First Last"
      }

      assert {:ok, %FamilyMemberInvitation{}} = Create.call(1, params)

      assert_called(Twilio.SMSClient, :send, [_, _], 1)
    end
  end
end
