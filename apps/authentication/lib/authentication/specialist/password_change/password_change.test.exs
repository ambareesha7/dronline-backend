defmodule Authentication.Specialist.PasswordChangeTest do
  use Postgres.DataCase, async: true

  import Mockery

  alias Authentication.Specialist.PasswordChange

  describe "create/2" do
    test "succeeds" do
      specialist = Authentication.Factory.insert(:specialist)

      assert {:ok, password_change} = PasswordChange.create(specialist.id, "Password1!")

      assert password_change.specialist_id == specialist.id
    end

    test "loops on confirmation_token unique constraint error" do
      other_specialist = Authentication.Factory.insert(:specialist)
      specialist = Authentication.Factory.insert(:specialist)

      {:ok, other_specialist} = PasswordChange.create(other_specialist.id, "Password1!")

      mock(Authentication.Random, [url_safe: 1], fn _ ->
        mock(Authentication.Random, [url_safe: 1], fn _ ->
          Authentication.Random.url_safe()
        end)

        other_specialist.confirmation_token
      end)

      {:ok, updated_specialist} = PasswordChange.create(specialist.id, "Password1!")

      assert updated_specialist.confirmation_token
    end

    test "returns {:error, changeset} if password is invalid" do
      specialist = Authentication.Factory.insert(:specialist)

      assert {:error, %Ecto.Changeset{}} = PasswordChange.create(specialist.id, "pass")
    end
  end

  describe "fetch_by_confirmation_token/1" do
    test "returns {:ok, password_change} when token exists and is valid" do
      specialist = Authentication.Factory.insert(:specialist)

      password_change =
        Authentication.Factory.insert(:password_change, specialist_id: specialist.id)

      assert {:ok, fetched_password_change} =
               PasswordChange.fetch_by_confirmation_token(password_change.confirmation_token)

      assert password_change.id == fetched_password_change.id
    end

    test "returns {:error, :not_found} when token exists but has expired" do
      specialist = Authentication.Factory.insert(:specialist)

      password_change =
        Authentication.Factory.insert(:password_change, specialist_id: specialist.id)

      datetime_in_the_past = Timex.now() |> Timex.shift(hours: -1) |> Timex.to_naive_datetime()

      password_change
      |> Ecto.Changeset.change(expire_at: datetime_in_the_past)
      |> Postgres.Repo.update()

      assert {:error, :not_found} =
               PasswordChange.fetch_by_confirmation_token(password_change.confirmation_token)
    end

    test "returns {:error, :not_found} when token doesn't exists" do
      assert {:error, :not_found} = PasswordChange.fetch_by_confirmation_token("")
    end
  end
end
