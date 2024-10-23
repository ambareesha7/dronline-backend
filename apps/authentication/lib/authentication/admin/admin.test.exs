defmodule Authentication.AdminTest do
  use Postgres.DataCase, async: true

  alias Authentication.Admin

  describe "create/1" do
    test "creates new admin" do
      params = %{
        email: "test@example.com",
        password: "Password1!"
      }

      {:ok, admin} = Admin.create(params)

      assert admin.email == "test@example.com"
    end

    test "validation error" do
      params = %{password: "Password1!"}

      {:error, changeset} = Admin.create(params)

      assert "can't be blank" in errors_on(changeset).email
    end
  end

  describe "fetch_by_auth_token/1" do
    test "returns admin data when auth token is valid" do
      admin = Authentication.Factory.insert(:admin)

      assert {:ok, fetched} = Admin.fetch_by_auth_token(admin.auth_token)

      assert fetched.id == admin.id
    end

    test "returns error when auth token is invalid" do
      assert {:error, :not_found} = Admin.fetch_by_auth_token("invalid")
    end
  end

  describe "fetch_by_email/1" do
    test "returns verified admin when email is valid" do
      admin = Authentication.Factory.insert(:admin)

      assert {:ok, fetched} = Admin.fetch_by_email(admin.email)

      assert fetched.id == admin.id
    end

    test "returns error when email is invalid" do
      assert {:error, :not_found} = Admin.fetch_by_email("invalid")
    end
  end
end
