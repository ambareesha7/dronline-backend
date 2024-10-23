defmodule Authentication.Specialist.PasswordChange.ConfirmTest do
  use Postgres.DataCase, async: true

  alias Authentication.Specialist
  alias Authentication.Specialist.PasswordChange
  alias Authentication.Specialist.PasswordChange.Confirm

  describe "call/1" do
    test "succedes when confirmation_token is valid" do
      specialist = Authentication.Factory.insert(:specialist)

      password_change =
        Authentication.Factory.insert(:password_change, specialist_id: specialist.id)

      assert :ok = Confirm.call(password_change.confirmation_token)

      {:ok, fetched_specialist} = Specialist.fetch_by_id(specialist.id)
      assert fetched_specialist.password_hash == password_change.password_hash

      # password change should be deleted after confirming
      assert {:error, :not_found} =
               PasswordChange.fetch_by_confirmation_token(password_change.confirmation_token)
    end

    test "returns error when confirmation_token isn't valid" do
      assert {:error, :not_found} = Confirm.call("")
    end
  end
end
