defmodule Insurance.AccountsTest do
  use Postgres.DataCase, async: true

  alias Insurance.Accounts
  alias Insurance.Accounts.Account
  alias Insurance.Accounts.Patient
  alias Insurance.Accounts.PatientBasicInfo
  alias Insurance.Providers.Provider

  describe "create/1" do
    test """
    - creates a new Insurance Account, ignores request with same params
    - updates Patient's insurance_account_id
    """ do
      patient = Insurance.Factory.insert(:patient, [])
      _basic_info = Insurance.Factory.insert(:patient_basic_info, patient_id: patient.id)
      country = Postgres.Factory.insert(:country, [])

      provider =
        Insurance.Factory.insert(:provider, %{
          name: "provider_name",
          country_id: country.id
        })

      assert {:ok,
              %Account{
                id: account_id,
                member_id: "member_id"
              }} =
               Accounts.set(
                 %{
                   provider_id: provider.id,
                   member_id: "member_id"
                 },
                 patient.id
               )

      assert {:ok,
              %Account{
                id: _,
                member_id: "member_id",
                insurance_provider: %Provider{
                  id: _,
                  name: "provider_name"
                }
              }} =
               Accounts.set(
                 %{
                   provider_id: provider.id,
                   member_id: "member_id"
                 },
                 patient.id
               )

      assert [_] = Repo.all(Account)
      assert Repo.one(Patient).insurance_account_id == account_id

      assert %{
               is_insured: true,
               insurance_provider_name: "provider_name",
               insurance_member_id: "member_id"
             } = Repo.one(PatientBasicInfo)
    end

    test """
    - error if one of required fields is empty
    """ do
      patient = Insurance.Factory.insert(:patient, [])
      _basic_info = Insurance.Factory.insert(:patient_basic_info, patient_id: patient.id)
      country = Postgres.Factory.insert(:country, [])

      provider =
        Insurance.Factory.insert(:provider, %{
          name: "provider_name",
          country_id: country.id
        })

      assert {:error, _} =
               Accounts.set(
                 %{
                   provider_id: provider.id,
                   member_id: ""
                 },
                 patient.id
               )

      assert [] = Repo.all(Account)
    end
  end

  describe "get_for_patient/1" do
    test "returns insurance details or nil" do
      patient = Insurance.Factory.insert(:patient, [])
      _basic_info = Insurance.Factory.insert(:patient_basic_info, patient_id: patient.id)
      country = Postgres.Factory.insert(:country, [])

      patient_2 = Insurance.Factory.insert(:patient, [])

      provider =
        Insurance.Factory.insert(:provider, %{
          name: "provider_name",
          country_id: country.id
        })

      {:ok,
       %Account{
         id: _account_id
       }} =
        Accounts.set(
          %{
            provider_id: provider.id,
            member_id: "member_id"
          },
          patient.id
        )

      assert {:ok,
              %Account{
                id: _,
                member_id: "member_id",
                insurance_provider: %Provider{
                  id: _,
                  name: "provider_name"
                }
              }} = Accounts.get_for_patient(patient.id)

      assert {:ok, nil} = Accounts.get_for_patient(patient_2.id)
    end
  end

  describe "remove_for_patient/1" do
    test "sets Patient's insurance to empty value" do
      patient = Insurance.Factory.insert(:patient, [])
      _basic_info = Insurance.Factory.insert(:patient_basic_info, patient_id: patient.id)
      country = Postgres.Factory.insert(:country, [])

      provider =
        Insurance.Factory.insert(:provider, %{
          name: "provider_name",
          country_id: country.id
        })

      {:ok, _} =
        Accounts.set(
          %{
            provider_id: provider.id,
            member_id: "member_id"
          },
          patient.id
        )

      assert {:ok, %Account{}} = Accounts.get_for_patient(patient.id)
      assert {:ok, nil} = Accounts.remove_for_patient(patient.id)
      assert {:ok, nil} = Accounts.get_for_patient(patient.id)

      assert %{
               is_insured: false,
               insurance_provider_name: nil,
               insurance_member_id: nil
             } = Repo.one(PatientBasicInfo)
    end
  end
end
