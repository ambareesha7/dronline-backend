defmodule Calls.FamilyMemberInvitationTest do
  use Postgres.DataCase, async: true

  alias Calls.FamilyMemberInvitation

  describe "fetch_by_id/1" do
    test "returns {:error, :not_found}" do
      assert {:error, :not_found} = FamilyMemberInvitation.fetch_by_id("non_existing_id")
    end

    test "returns {:ok, invitation}" do
      params = %{
        call_id: "call_id",
        session_id: "session_id",
        patient_id: 1,
        session_token: "session_token",
        phone_number: "+38012345678",
        name: "First Last"
      }

      {:ok, invitation} = FamilyMemberInvitation.create(params)

      assert {:ok, %FamilyMemberInvitation{}} = FamilyMemberInvitation.fetch_by_id(invitation.id)
    end
  end
end
