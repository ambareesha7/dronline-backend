defmodule Authentication.Patient.CreateNoSignUpAccountTest do
  use Postgres.DataCase, async: true
  alias Authentication.Patient.CreateNoSignUpAccount

  describe "call/1" do
    setup do
      {:ok, phone_number: "+48661848585"}
    end

    test "returns account, when it already exists", %{phone_number: phone_number} do
      {:ok, account} =
        Authentication.Patient.Account.create(%{
          firebase_id: "firebase_id",
          main_patient_id: 1,
          phone_number: phone_number
        })

      Authentication.Patient.AuthTokenEntry.create(account.main_patient_id)

      assert {:ok, %{patient_account: ^account, auth_token: auth_token}} =
               CreateNoSignUpAccount.call(%{
                 phone_number: phone_number,
                 email: "e@mail.com",
                 first_name: "Joe",
                 last_name: "Doe"
               })

      assert auth_token
    end

    test "creates the account with basic data", %{phone_number: phone_number} do
      result =
        CreateNoSignUpAccount.call(%{
          phone_number: phone_number,
          email: "e@mail.com",
          first_name: "Joe",
          last_name: "Doe"
        })

      assert {:ok,
              %{
                patient_account: %Authentication.Patient.Account{
                  firebase_id: nil,
                  id: account_id,
                  main_patient_id: main_patient_id,
                  phone_number: ^phone_number,
                  is_signed_up: false
                },
                auth_token: auth_token
              }} =
               result

      assert account_id
      assert auth_token

      assert {:ok,
              %PatientProfile.BasicInfo{
                id: _basic_info_id,
                birth_date: nil,
                email: "e@mail.com",
                first_name: "Joe",
                last_name: "Doe",
                title: nil,
                gender: nil,
                is_insured: false,
                insurance_provider_name: nil,
                insurance_member_id: nil,
                avatar_resource_path: "/other_test_default_avatar",
                patient_id: ^main_patient_id
              }} = PatientProfile.fetch_basic_info(main_patient_id)
    end

    test "returns errors, when patient data is invalid", %{phone_number: phone_number} do
      result =
        CreateNoSignUpAccount.call(%{
          phone_number: "invalid",
          email: "e@mail.com",
          first_name: "Joe",
          last_name: "Doe"
        })

      assert match?({:error, %Ecto.Changeset{valid?: false, errors: [phone_number: _]}}, result)

      result =
        CreateNoSignUpAccount.call(%{
          phone_number: phone_number,
          email: "e@mail.com",
          first_name: "Joe",
          last_name: nil
        })

      assert match?({:error, %Ecto.Changeset{valid?: false, errors: [last_name: _]}}, result)
    end
  end
end
