defmodule SpecialistProfile.SpecialistTest do
  use Postgres.DataCase, async: true

  describe "fetch_all_by_category/1" do
    test "returns all specialists with given category" do
      category = SpecialistProfile.Factory.insert(:medical_category)
      doctor = Authentication.Factory.insert(:verified_and_approved_external)

      {:ok, _medical_categories} =
        SpecialistProfile.Specialist.update_categories(
          [
            category.id
          ],
          doctor.id
        )

      assert [{fetched_id}] = SpecialistProfile.Specialist.fetch_all_by_category(category.id)
      assert fetched_id == doctor.id
    end
  end

  describe "update_categories/2" do
    test "assign given categories to doctor" do
      category1 = SpecialistProfile.Factory.insert(:medical_category)
      category2 = SpecialistProfile.Factory.insert(:medical_category)
      doctor = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      assert {:ok, medical_categories} =
               SpecialistProfile.Specialist.update_categories(
                 [
                   category1.id,
                   category2.id
                 ],
                 doctor.id
               )

      assert length(medical_categories) == 2
    end

    test "doctor can unassign categories" do
      category1 = SpecialistProfile.Factory.insert(:medical_category)
      category2 = SpecialistProfile.Factory.insert(:medical_category)
      doctor = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      assert {:ok, medical_categories} =
               SpecialistProfile.Specialist.update_categories(
                 [
                   category1.id,
                   category2.id
                 ],
                 doctor.id
               )

      assert length(medical_categories) == 2

      assert {:ok, medical_categories} =
               SpecialistProfile.Specialist.update_categories([category1.id], doctor.id)

      assert length(medical_categories) == 1
    end
  end

  describe "update_insurance_providers/2" do
    setup do
      country = Postgres.Factory.insert(:country, [])

      insurance_provider1 =
        Insurance.Factory.insert(:provider, name: "provider_name1", country_id: country.id)

      insurance_provider2 =
        Insurance.Factory.insert(:provider, name: "provider_name2", country_id: country.id)

      specialist = Authentication.Factory.insert(:specialist)

      {:ok,
       insurance_provider1: insurance_provider1,
       insurance_provider2: insurance_provider2,
       specialist: specialist}
    end

    test "assigns given insurance providers to specialist", %{
      insurance_provider1: insurance_provider1,
      insurance_provider2: insurance_provider2,
      specialist: specialist
    } do
      assert {:ok, insurance_providers} =
               SpecialistProfile.Specialist.update_insurance_providers(
                 specialist.id,
                 [
                   insurance_provider1.id,
                   insurance_provider2.id
                 ]
               )

      assert [
               %SpecialistProfile.Insurances.Provider{
                 name: "provider_name1"
               },
               %SpecialistProfile.Insurances.Provider{
                 name: "provider_name2"
               }
             ] = Enum.sort_by(insurance_providers, & &1.name)
    end

    test "doctor can unassign categories", %{
      insurance_provider1: insurance_provider1,
      insurance_provider2: insurance_provider2,
      specialist: specialist
    } do
      assert {:ok, insurance_providers} =
               SpecialistProfile.Specialist.update_insurance_providers(
                 specialist.id,
                 [
                   insurance_provider1.id,
                   insurance_provider2.id
                 ]
               )

      assert length(insurance_providers) == 2

      assert {:ok, insurance_providers} =
               SpecialistProfile.Specialist.update_insurance_providers(
                 specialist.id,
                 [
                   insurance_provider1.id
                 ]
               )

      assert [
               %SpecialistProfile.Insurances.Provider{
                 name: "provider_name1"
               }
             ] = insurance_providers
    end
  end
end
