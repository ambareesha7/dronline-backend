defmodule Authentication.SpecialistServiceTest do
  use Postgres.DataCase, async: true
  import Mockery

  alias Authentication.Specialist

  describe "register/1" do
    test "creates new specialist" do
      params = %{
        type: "EXTERNAL",
        email: "test@example.com",
        password: "Password1!"
      }

      {:ok, specialist} = Specialist.register(params)

      assert specialist.type == "EXTERNAL"
      assert specialist.email == "test@example.com"
    end

    test "validation errors" do
      params = %{email: "test@example.com", password: "Password1!"}

      assert {:error, changeset} = Specialist.register(params)

      assert "can't be blank" in errors_on(changeset).type

      params = %{
        type: "EXTERNAL",
        email: "test@example.com",
        password: "Password1"
      }

      assert {:error, changeset} = Specialist.register(params)
      assert "must contain at least 1 special character" in errors_on(changeset).password

      params = %{params | password: "password1!"}
      assert {:error, changeset} = Specialist.register(params)
      assert "must contain at least 1 uppercase character" in errors_on(changeset).password

      params = %{params | password: "PASSWORD1!"}
      assert {:error, changeset} = Specialist.register(params)
      assert "must contain at least 1 lowercase character" in errors_on(changeset).password

      params = %{params | password: "Password!"}
      assert {:error, changeset} = Specialist.register(params)
      assert "must contain at least 1 digit" in errors_on(changeset).password
    end

    test "email already taken if verified account exists" do
      Authentication.Factory.insert(
        :verified_specialist,
        email: "verified@example.com"
      )

      params = %{
        type: "EXTERNAL",
        email: "verified@example.com",
        password: "Password1!"
      }

      {:error, :email_taken} = Specialist.register(params)
    end

    test "update if unverified account exists" do
      unverified_specialist =
        Authentication.Factory.insert(
          :specialist,
          email: "unverified@example.com"
        )

      params = %{
        type: "EXTERNAL",
        email: "unverified@example.com",
        password: "Password1!"
      }

      {:ok, updated_specialist} = Specialist.register(params)

      assert updated_specialist.id == unverified_specialist.id
    end

    test "loops on verification_token unique constraint error" do
      other_specialist = Authentication.Factory.insert(:specialist)

      # OMFG possible new feature in Mockery
      mock(Authentication.Random, [url_safe: 1], fn _ ->
        mock(Authentication.Random, [url_safe: 1], fn _ ->
          mock(Authentication.Random, [url_safe: 1], fn _ ->
            Authentication.Random.url_safe()
          end)

          other_specialist.verification_token
        end)

        "auth_token"
      end)

      params = %{
        type: "EXTERNAL",
        email: "test@example.com",
        password: "Password1!"
      }

      {:ok, _id} = Specialist.register(params)
    end

    test "loops on auth_token unique constraint error" do
      other_specialist = Authentication.Factory.insert(:specialist)

      # OMFG possible new feature in Mockery
      mock(Authentication.Random, [url_safe: 1], fn _ ->
        mock(Authentication.Random, [url_safe: 1], fn _ ->
          Authentication.Random.url_safe()
        end)

        other_specialist.auth_token
      end)

      params = %{
        type: "EXTERNAL",
        email: "test@example.com",
        password: "Password1!"
      }

      {:ok, _id} = Specialist.register(params)
    end
  end

  describe "verify/1" do
    test "sets unverified specialist as verified" do
      unverified_specialist = Authentication.Factory.insert(:specialist)

      {:ok, %{verified: true} = verified_specialist} = Specialist.verify(unverified_specialist)

      assert verified_specialist.id == unverified_specialist.id
      assert unverified_specialist.verification_token
      refute verified_specialist.verification_token
    end

    test "doesn't change already verified specialist" do
      unverified_specialist = Authentication.Factory.insert(:specialist)
      {:ok, %{verified: true} = verified_specialist} = Specialist.verify(unverified_specialist)
      {:ok, %{verified: true} = unchanged_specialist} = Specialist.verify(verified_specialist)

      assert verified_specialist == unchanged_specialist
    end
  end

  describe "fetch_by_auth_token/1" do
    test "returns verified specialist data when auth token is valid" do
      verified_specialist = Authentication.Factory.insert(:verified_specialist)

      {:ok, fetched} = Specialist.fetch_by_auth_token(verified_specialist.auth_token)

      assert fetched.id == verified_specialist.id
    end

    test "returns error when specialist is not verified" do
      unverified_specialist = Authentication.Factory.insert(:specialist)

      {:error, :not_found} = Specialist.fetch_by_auth_token(unverified_specialist.auth_token)
    end

    test "returns error when auth token is invalid" do
      {:error, :not_found} = Specialist.fetch_by_auth_token("invalid")
    end
  end

  describe "fetch_by_email/1" do
    test "returns verified specialist when email is valid" do
      verified_specialist = Authentication.Factory.insert(:verified_specialist)

      {:ok, fetched} = Specialist.fetch_by_email(verified_specialist.email)

      assert fetched.id == verified_specialist.id
    end

    test "returns unverifed specialist when email is valid" do
      unverified_specialist = Authentication.Factory.insert(:specialist)

      {:ok, fetched} = Specialist.fetch_by_email(unverified_specialist.email)

      assert fetched.id == unverified_specialist.id
    end

    test "returns error when email is invalid" do
      {:error, :not_found} = Specialist.fetch_by_email("invalid")
    end
  end

  describe "fetch_by_verified_email/1" do
    test "returns verified specialist when email is valid" do
      verified_specialist = Authentication.Factory.insert(:verified_specialist)

      {:ok, fetched} = Specialist.fetch_by_verified_email(verified_specialist.email)

      assert fetched.id == verified_specialist.id
    end

    test "returns error when email is invalid" do
      {:error, :not_found} = Specialist.fetch_by_verified_email("invalid")
    end

    test "returns error when specialist is unverified" do
      unverified_specialist = Authentication.Factory.insert(:specialist)

      {:error, :not_found} = Specialist.fetch_by_verified_email(unverified_specialist.email)
    end
  end

  describe "fetch_by_verification_token/1" do
    test "returns specialist when verification_token is valid" do
      specialist = Authentication.Factory.insert(:specialist)

      {:ok, fetched} = Specialist.fetch_by_verification_token(specialist.verification_token)

      assert fetched.id == specialist.id
    end

    test "returns error when email is invalid" do
      {:error, :not_found} = Specialist.fetch_by_verification_token("invalid")
    end
  end

  describe "update_password_hash/2" do
    test "updates password hash and generate new auth token when specialist exists" do
      specialist = Authentication.Factory.insert(:specialist)

      _other_specialist = Authentication.Factory.insert(:specialist)

      assert {:ok, updated_specialist} =
               Specialist.update_password_hash(specialist.id, "new_hash")

      assert updated_specialist.password_hash == "new_hash"
      assert specialist.auth_token != updated_specialist.auth_token
    end

    test "loops on auth_token unique constraint error" do
      other_specialist = Authentication.Factory.insert(:specialist)

      mock(Authentication.Random, [url_safe: 1], fn _ ->
        mock(Authentication.Random, [url_safe: 1], fn _ ->
          Authentication.Random.url_safe()
        end)

        other_specialist.auth_token
      end)

      specialist = Authentication.Factory.insert(:specialist)
      {:ok, updated_specialist} = Specialist.update_password_hash(specialist.id, "new_hash")

      assert updated_specialist.auth_token
    end
  end

  describe "create_password_recovery_token/1" do
    test "creates password_recovery_token and its expiration datetime" do
      specialist = Authentication.Factory.insert(:specialist)

      {:ok, updated_specialist} = Specialist.create_password_recovery_token(specialist)

      assert updated_specialist.password_recovery_token
      assert updated_specialist.password_recovery_token_expire_at
    end

    test "loops on password_recovery_token unique constraint error" do
      other_specialist = Authentication.Factory.insert(:specialist)
      {:ok, other_specialist} = Specialist.create_password_recovery_token(other_specialist)

      mock(Authentication.Random, [url_safe: 1], fn _ ->
        mock(Authentication.Random, [url_safe: 1], fn _ ->
          Authentication.Random.url_safe()
        end)

        other_specialist.password_recovery_token
      end)

      specialist = Authentication.Factory.insert(:specialist)
      {:ok, updated_specialist} = Specialist.create_password_recovery_token(specialist)

      assert updated_specialist.password_recovery_token
    end
  end

  describe "fetch_by_password_recovery_token/1" do
    test "returns verified specialist id when email token is valid" do
      specialist = Authentication.Factory.insert(:specialist_during_password_recovery)

      {:ok, fetched_specialist} =
        Specialist.fetch_by_password_recovery_token(specialist.password_recovery_token)

      assert fetched_specialist.id == specialist.id
    end

    test "returns error when auth token is expired" do
      specialist = Authentication.Factory.insert(:specialist_during_password_recovery)

      datetime_in_the_past = Timex.now() |> Timex.shift(hours: -1) |> Timex.to_naive_datetime()

      specialist
      |> Ecto.Changeset.change(password_recovery_token_expire_at: datetime_in_the_past)
      |> Postgres.Repo.update()

      {:error, :not_found} = Specialist.fetch_by_password_recovery_token("invalid")
    end

    test "returns error when auth token is invalid" do
      {:error, :not_found} = Specialist.fetch_by_password_recovery_token("invalid")
    end

    test "returns error when specialist is unverified" do
      unverified_specialist = Authentication.Factory.insert(:specialist)
      {:ok, specialist} = Specialist.create_password_recovery_token(unverified_specialist)

      {:error, :not_found} =
        Specialist.fetch_by_password_recovery_token(specialist.password_recovery_token)
    end
  end

  describe "set_new_password/2" do
    test "updates specialist when new password is valid and generates new auth token" do
      specialist = Authentication.Factory.insert(:specialist_during_password_recovery)

      {:ok, fetched_specialist} = Specialist.set_new_password(specialist, "NewPassword0)")

      assert specialist.password_recovery_token
      refute fetched_specialist.password_recovery_token
      assert fetched_specialist.password_hash != specialist.password_hash
      assert fetched_specialist.auth_token != specialist.auth_token
    end

    test "returns validation errors when new password is invalid" do
      specialist = Authentication.Factory.insert(:specialist_during_password_recovery)

      {:error, changeset} = Specialist.set_new_password(specialist, "")
      assert "can't be blank" in errors_on(changeset).password
    end

    test "loops on auth_token unique constraint error" do
      other_specialist = Authentication.Factory.insert(:specialist)

      mock(Authentication.Random, [url_safe: 1], fn _ ->
        mock(Authentication.Random, [url_safe: 1], fn _ ->
          Authentication.Random.url_safe()
        end)

        other_specialist.auth_token
      end)

      specialist = Authentication.Factory.insert(:specialist)
      {:ok, updated_specialist} = Specialist.set_new_password(specialist, "NewPassword0)")

      assert updated_specialist.auth_token
    end
  end
end
