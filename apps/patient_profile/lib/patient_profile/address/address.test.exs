defmodule PatientProfile.AddressTest do
  use Postgres.DataCase, async: true

  alias PatientProfile.Address

  describe "update/2" do
    test "creates new address when it doesn't exist" do
      patient = PatientProfile.Factory.insert(:patient)

      params = %{
        street: "street",
        home_number: "home number",
        zip_code: "zip code",
        city: "city",
        country: "country",
        neighborhood: "neighborhood"
      }

      {:ok, %Address{city: "city"}} = Address.update(params, patient.id)
    end

    test "updates address when it exists" do
      patient = PatientProfile.Factory.insert(:patient)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id, city: "city1")
      params = %{city: "city2"}

      {:ok, %Address{city: "city2"}} = Address.update(params, patient.id)
    end

    test "returns validation errors" do
      patient = PatientProfile.Factory.insert(:patient)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)
      params = %{city: ""}

      {:error, %Ecto.Changeset{}} = Address.update(params, patient.id)
    end
  end
end
