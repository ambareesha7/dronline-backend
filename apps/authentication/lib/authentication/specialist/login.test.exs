defmodule Authentication.Specialist.LoginTest do
  use Postgres.DataCase, async: true

  alias Authentication.Specialist.Login

  describe "call/2" do
    test "valid credentials for verified specialist" do
      verified_specialist =
        Authentication.Factory.insert(:verified_specialist,
          email: "test@example.com",
          password: "Password1!"
        )

      {:ok, %{auth_token: token}} = Login.call("test@example.com", "Password1!")

      {:ok, logged_in_specialist} = Authentication.authenticate_specialist(token)
      assert logged_in_specialist.id == verified_specialist.id
    end

    test "logging in on multiple devices" do
      _verified_specialist =
        Authentication.Factory.insert(:verified_specialist,
          email: "test@example.com",
          password: "Password1!"
        )

      {:ok, first} = Login.call("test@example.com", "Password1!")
      {:ok, second} = Login.call("test@example.com", "Password1!")

      assert {:ok, _} = Authentication.authenticate_specialist(first.auth_token)
      assert {:ok, _} = Authentication.authenticate_specialist(second.auth_token)
    end

    test "ignore email characters case" do
      _verified_specialist =
        Authentication.Factory.insert(:verified_specialist,
          email: "test@example.com",
          password: "Password1!"
        )

      {:ok, _specialist} = Login.call("TEST@example.com", "Password1!")
    end

    test "valid credentials for unverified specialist" do
      _unverified_specialist =
        Authentication.Factory.insert(:specialist,
          email: "test@example.com",
          password: "Password1!"
        )

      assert {:error,
              "You have not verified your email address. Please check your inbox to verify your account"} =
               Login.call("test@example.com", "Password1!")
    end

    test "invalid password" do
      _verified_specialist =
        Authentication.Factory.insert(:verified_specialist,
          email: "test@example.com",
          password: "Password1!"
        )

      assert {:error, :unauthorized} = Login.call("test@example.com", "Invalid")
    end

    test "invalid email" do
      _verified_specialist =
        Authentication.Factory.insert(:verified_specialist,
          email: "test@example.com",
          password: "Password1!"
        )

      assert {:error, :unauthorized} = Login.call("invalid", "Password1!")
    end
  end
end
