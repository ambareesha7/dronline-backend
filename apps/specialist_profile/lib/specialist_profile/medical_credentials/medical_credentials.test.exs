defmodule SpecialistProfile.MedicalCredentialsTest do
  use Postgres.DataCase, async: true

  alias SpecialistProfile.MedicalCredentials
  alias SpecialistProfile.Status

  describe "fetch_by_specialist_id/1" do
    test "returns medical credentials when specialist_id is valid" do
      specialist = Authentication.Factory.insert(:specialist)

      medical_credentials =
        SpecialistProfile.Factory.insert(:medical_credentials, specialist_id: specialist.id)

      {:ok, fetched} = MedicalCredentials.fetch_by_specialist_id(specialist.id)

      assert fetched.dea_number_url == medical_credentials.dea_number_url
    end

    test "returns empty medical credentials when specialist_id is invalid" do
      {:ok, %MedicalCredentials{id: nil}} = MedicalCredentials.fetch_by_specialist_id(0)
    end
  end

  describe "update/2" do
    test "creates new medical credentials when it doesn't exist" do
      specialist = Authentication.Factory.insert(:specialist)

      params = %{
        dea_number_url: "random_url",
        dea_number_expiry_date: ~D[2018-11-08],
        board_certification_url: "random_url",
        board_certification_expiry_date: ~D[2018-11-08],
        current_state_license_number_url: "random_url",
        current_state_license_number_expiry_date: ~D[2018-11-08]
      }

      {:ok, %{dea_number_url: "random_url"}} = MedicalCredentials.update(params, specialist.id)
    end

    test "updates medical credentials when it exists" do
      specialist = Authentication.Factory.insert(:specialist)

      _medical_credentials =
        SpecialistProfile.Factory.insert(:medical_credentials,
          specialist_id: specialist.id,
          dea_number_url: "random_url"
        )

      params = %{dea_number_url: "not_random_url"}

      {:ok, %{dea_number_url: "not_random_url"}} =
        MedicalCredentials.update(params, specialist.id)
    end

    test "updates basic info and sets onboarding as completed for freelancers" do
      specialist =
        Authentication.Factory.insert(:not_onboarded_verified_specialist, type: "EXTERNAL")

      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)
      _location = SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)

      medical_category = SpecialistProfile.Factory.insert(:medical_category)

      {:ok, [specialist_medical_category]} =
        SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      _ =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: specialist.id,
          medical_category_id: specialist_medical_category.id
        )

      assert {:ok, %{onboarding_completed: false}} = Status.fetch_by_specialist_id(specialist.id)

      params = %{
        dea_number_url: "random_url",
        dea_number_expiry_date: ~D[2018-11-08],
        board_certification_url: "random_url",
        board_certification_expiry_date: ~D[2018-11-08],
        current_state_license_number_url: "random_url",
        current_state_license_number_expiry_date: ~D[2018-11-08]
      }

      {:ok, %{dea_number_url: "random_url"}} = MedicalCredentials.update(params, specialist.id)

      assert {:ok, %{onboarding_completed: true}} = Status.fetch_by_specialist_id(specialist.id)
    end
  end
end
