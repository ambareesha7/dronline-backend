defmodule Payouts.CredentialsTest do
  use Postgres.DataCase, async: true

  alias Payouts.Credentials

  describe "fetch_by_specialist_id/1" do
    test "fetches credentials if they exist" do
      specialist_id = 1
      Payouts.Factory.insert(:credentials, specialist_id: specialist_id, iban: "12345")

      assert {:ok,
              %Credentials{
                iban: "12345"
              }} = Credentials.fetch_by_specialist_id(specialist_id)
    end

    test "returns nil if credentials don't exist" do
      specialist_id = 1

      assert {:ok, nil} = Credentials.fetch_by_specialist_id(specialist_id)
    end
  end

  describe "update/2" do
    test "updates credentials if they exist" do
      specialist_id = 1
      Payouts.Factory.insert(:credentials, specialist_id: specialist_id, iban: "0000")

      params = %{
        iban: "12345",
        name: "name",
        bank_name: "bank_name",
        bank_swift_code: "bank_swift_code"
      }

      assert {:ok,
              %{
                specialist_id: 1,
                iban: "12345"
              }} = Credentials.update(params, specialist_id)
    end

    test "creates credentials if they don't exist" do
      specialist_id = 1

      params = %{
        iban: "12345",
        name: "name",
        bank_name: "bank_name",
        bank_swift_code: "bank_swift_code"
      }

      assert {:ok,
              %{
                specialist_id: 1,
                iban: "12345"
              }} = Credentials.update(params, specialist_id)
    end
  end
end
