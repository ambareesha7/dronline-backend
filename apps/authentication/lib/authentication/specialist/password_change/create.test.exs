defmodule Authentication.Specialist.PasswordChange.CreateTest do
  use Postgres.DataCase, async: true

  alias Authentication.Specialist.PasswordChange
  alias Authentication.Specialist.PasswordChange.Create

  describe "call/2" do
    test "succeeds when params are valid" do
      specialist = Authentication.Factory.insert(:specialist)

      assert {:ok, _oban_job} = Create.call(specialist.id, "Password1!")

      assert {:ok, _password_change} =
               Postgres.Repo.fetch_by(PasswordChange, specialist_id: specialist.id)
    end

    test "returns error when params are invalid" do
      specialist = Authentication.Factory.insert(:specialist)

      assert {:error, %Ecto.Changeset{}} = Create.call(specialist.id, "password1!")
    end
  end
end
