defmodule SpecialistProfile.StatusTest do
  use Postgres.DataCase, async: true

  alias SpecialistProfile.Status

  describe "fetch_by_specialist_id/1" do
    test "success" do
      specialist = Authentication.Factory.insert(:not_onboarded_specialist, type: "EXTERNAL")

      assert {:ok, %{onboarding_completed: false}} = Status.fetch_by_specialist_id(specialist.id)
    end
  end

  describe "handle_onboarding_status/1" do
    test "set onboarding as completed for freelancers only if all parts of profile are provided" do
      specialist =
        Authentication.Factory.insert(:not_onboarded_verified_specialist, type: "EXTERNAL")

      params = %{
        title: "MR",
        gender: "MALE",
        first_name: "FN",
        last_name: "LN",
        birth_date: ~D[1988-11-13],
        image_url: "http://example.com/image/jpg",
        phone_number: "random_number"
      }

      {:ok, _basic_info} = SpecialistProfile.update_basic_info(params, specialist.id)

      assert {:ok, %{onboarding_completed: false}} = Status.fetch_by_specialist_id(specialist.id)

      params = %{
        street: "random_string",
        number: "random_string",
        postal_code: "random_string",
        city: "Poznan",
        country: "random_string",
        neighborhood: "random_string",
        formatted_address: "random_string",
        coordinates: %{
          lat: 80.00001,
          lon: 20.00001
        }
      }

      {:ok, _location} = SpecialistProfile.update_location(params, specialist.id)

      assert {:ok, %{onboarding_completed: false}} = Status.fetch_by_specialist_id(specialist.id)

      category = SpecialistProfile.Factory.insert(:medical_category)
      category2 = SpecialistProfile.Factory.insert(:medical_category)

      {:ok, [specialist_medical_category, specialist_medical_category2]} =
        SpecialistProfile.Specialist.update_categories([category.id, category2.id], specialist.id)

      assert {:ok, %{onboarding_completed: false}} = Status.fetch_by_specialist_id(specialist.id)

      params = %{
        dea_number_url: "random_url",
        dea_number_expiry_date: ~D[2018-11-08],
        board_certification_url: "random_url",
        board_certification_expiry_date: ~D[2018-11-08],
        current_state_license_number_url: "random_url",
        current_state_license_number_expiry_date: ~D[2018-11-08]
      }

      {:ok, _medical_credentials} =
        SpecialistProfile.update_medical_credentials(params, specialist.id)

      assert {:ok, %{onboarding_completed: false}} = Status.fetch_by_specialist_id(specialist.id)

      _prices =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: specialist.id,
          medical_category_id: specialist_medical_category.id
        )

      assert {:ok, %{onboarding_completed: false}} = Status.fetch_by_specialist_id(specialist.id)

      _prices =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: specialist.id,
          medical_category_id: specialist_medical_category2.id
        )

      assert {:ok, %{onboarding_completed: true}} = Status.fetch_by_specialist_id(specialist.id)
    end

    test "set onboarding as completed for internals only if basic info is provided" do
      specialist = Authentication.Factory.insert(:not_onboarded_verified_specialist, type: "GP")

      assert {:ok, %{onboarding_completed: false}} = Status.fetch_by_specialist_id(specialist.id)

      params = %{
        title: "MR",
        gender: "MALE",
        first_name: "FN",
        last_name: "LN",
        birth_date: ~D[1988-11-13],
        image_url: "http://example.com/image/jpg",
        phone_number: "random_number"
      }

      {:ok, _basic_info} = SpecialistProfile.update_basic_info(params, specialist.id)

      assert {:ok, %{onboarding_completed: true}} = Status.fetch_by_specialist_id(specialist.id)
    end
  end
end
