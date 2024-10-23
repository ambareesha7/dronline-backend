defmodule SpecialistProfile.Insurances.ProviderTest do
  use Postgres.DataCase, async: true

  alias SpecialistProfile.Insurances.Provider

  setup do
    country = Postgres.Factory.insert(:country, [])

    {:ok,
     insurance_provider1:
       Insurance.Factory.insert(:provider, name: "provider_name1", country_id: country.id),
     insurance_provider2:
       Insurance.Factory.insert(:provider, name: "provider_name2", country_id: country.id)}
  end

  describe "fetch_by_ids/1" do
    test "returns all providers", %{
      insurance_provider1: insurance_provider1,
      insurance_provider2: insurance_provider2
    } do
      assert {:ok, providers} =
               Provider.fetch_by_ids([insurance_provider1.id, insurance_provider2.id])

      assert [
               %SpecialistProfile.Insurances.Provider{
                 name: "provider_name1"
               },
               %SpecialistProfile.Insurances.Provider{
                 name: "provider_name2"
               }
             ] = Enum.sort_by(providers, & &1.name)
    end
  end

  describe "fetch_by_specialist_id/1" do
    test "returns providers for specialist id", %{
      insurance_provider1: insurance_provider1,
      insurance_provider2: insurance_provider2
    } do
      specialist = Authentication.Factory.insert(:specialist)

      SpecialistProfile.Specialist.update_insurance_providers(
        specialist.id,
        [
          insurance_provider1.id,
          insurance_provider2.id
        ]
      )

      assert {:ok, providers} = Provider.fetch_by_specialist_id(specialist.id)

      assert [
               %SpecialistProfile.Insurances.Provider{
                 name: "provider_name1"
               },
               %SpecialistProfile.Insurances.Provider{
                 name: "provider_name2"
               }
             ] = Enum.sort_by(providers, & &1.name)
    end
  end
end
