defmodule VisitsScheduling.FeaturedDoctorsTest do
  use Postgres.DataCase, async: true

  alias VisitsScheduling.FeaturedDoctors

  describe "fetch/0" do
    test "doesn't returns internal doctors" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      {:ok, []} = FeaturedDoctors.fetch()
    end

    test "doesn't return external doctors without basic info" do
      specialist = Authentication.Factory.insert(:verified_specialist)

      medical_category = SpecialistProfile.Factory.insert(:medical_category)
      _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      {:ok, []} =
        FeaturedDoctors.fetch_for_category(%{
          "medical_category_id" => medical_category.id
        })
    end

    test "doesn't return other specialist types" do
      specialist = Authentication.Factory.insert(:specialist, type: "NURSE")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      {:ok, []} = FeaturedDoctors.fetch()
    end

    test "returns only verified externals with active silver or better package" do
      # doctor_basic is ignored (minimum_active_package = "SILVER")
      doctor_basic =
        Authentication.Factory.insert(:verified_and_approved_external, type: "EXTERNAL")

      _basic_info_2 =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: doctor_basic.id)

      specialist =
        Authentication.Factory.insert(:verified_and_approved_external, type: "EXTERNAL")

      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist.id,
        type: "SILVER"
      )

      specialist2 = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist2.id)

      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist2.id,
        type: "SILVER"
      )

      specialist3 = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist3.id)
      specialist3.id |> Admin.verify_external_specialist("REJECTED")

      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist3.id,
        type: "SILVER"
      )

      {:ok, fetched} = FeaturedDoctors.fetch()
      assert length(fetched) == 1
    end

    test "returns only external doctors with active silver or better package" do
      specialist_basic = Authentication.Factory.insert(:verified_and_approved_external)

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_basic.id)

      specialist_silver = Authentication.Factory.insert(:verified_and_approved_external)

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_silver.id)

      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist_silver.id,
        type: "SILVER"
      )

      specialist_gold = Authentication.Factory.insert(:verified_and_approved_external)

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_gold.id)

      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist_gold.id,
        type: "GOLD"
      )

      specialist_platinum = Authentication.Factory.insert(:verified_and_approved_external)

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_platinum.id)

      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist_platinum.id,
        type: "PLATINUM"
      )

      assert {:ok, featured_doctors} = FeaturedDoctors.fetch()
      assert length(featured_doctors) == 3
      refute Enum.find(featured_doctors, &(&1.id == specialist_basic))
    end
  end

  describe "fetch_for_category/1" do
    test "doesn't return internal doctors" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      medical_category = SpecialistProfile.Factory.insert(:medical_category, name: "Butthurt")
      _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      {:ok, []} =
        FeaturedDoctors.fetch_for_category(%{
          "medical_category_id" => medical_category.id
        })
    end

    test "doesn't return other specialist types" do
      specialist = Authentication.Factory.insert(:specialist, type: "NURSE")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      medical_category = SpecialistProfile.Factory.insert(:medical_category)

      {:ok, []} =
        FeaturedDoctors.fetch_for_category(%{
          "medical_category_id" => medical_category.id
        })
    end

    test "doesn't return specialist from other mecidal_categories" do
      specialist = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      medical_category = SpecialistProfile.Factory.insert(:medical_category)
      _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      other_medical_category = SpecialistProfile.Factory.insert(:medical_category)

      {:ok, []} =
        FeaturedDoctors.fetch_for_category(%{
          "medical_category_id" => other_medical_category.id
        })
    end

    test "returns only verified externals with active silver or better package" do
      medical_category = SpecialistProfile.Factory.insert(:medical_category)

      specialist =
        Authentication.Factory.insert(:verified_and_approved_external, type: "EXTERNAL")

      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)
      _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist.id,
        type: "SILVER"
      )

      specialist2 = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist2.id)
      _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist2.id)

      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist2.id,
        type: "SILVER"
      )

      specialist3 = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist3.id)
      specialist3.id |> Admin.verify_external_specialist("REJECTED")
      _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist3.id)

      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist3.id,
        type: "SILVER"
      )

      {:ok, fetched} =
        FeaturedDoctors.fetch_for_category(%{
          "medical_category_id" => medical_category.id
        })

      assert length(fetched) == 1
    end

    test "returns external with silver or better package before rest external doctors" do
      medical_category = SpecialistProfile.Factory.insert(:medical_category)

      # BASIC
      specialist_basic = Authentication.Factory.insert(:verified_and_approved_external)

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_basic.id)

      _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist_basic.id)

      # SILVER
      specialist_silver = Authentication.Factory.insert(:verified_and_approved_external)

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_silver.id)

      _ =
        SpecialistProfile.update_medical_categories(
          [medical_category.id],
          specialist_silver.id
        )

      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist_silver.id,
        type: "SILVER"
      )

      # PLATINUM
      specialist_platinum = Authentication.Factory.insert(:verified_and_approved_external)

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_platinum.id)

      _ =
        SpecialistProfile.update_medical_categories(
          [medical_category.id],
          specialist_platinum.id
        )

      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist_platinum.id,
        type: "PLATINUM"
      )

      # BASIC
      specialist_basic = Authentication.Factory.insert(:verified_and_approved_external)

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist_basic.id)

      _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist_basic.id)

      assert {:ok, [doctor0, doctor1, _doctor2, _doctor3]} =
               FeaturedDoctors.fetch_for_category(%{
                 "medical_category_id" => medical_category.id
               })

      assert doctor0.id == specialist_platinum.id
      assert doctor1.id == specialist_silver.id
    end
  end
end
