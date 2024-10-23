defmodule Admin.ExternalSpecialists.ExternalSpecialistTest do
  use Postgres.DataCase, async: true

  alias Admin.ExternalSpecialists.ExternalSpecialist

  describe "fetch/1" do
    setup do
      approved_specialist1 =
        insert_verified_external_with_onboarding_completed(first_name: "first_name")

      {:ok, approved_specialist1} =
        ExternalSpecialist.set_approval_status(approved_specialist1, "VERIFIED")

      rejected_specialist = insert_verified_external_with_onboarding_completed()

      {:ok, rejected_specialist} =
        ExternalSpecialist.set_approval_status(rejected_specialist, "REJECTED")

      approved_specialist2 = insert_verified_external_with_onboarding_completed()

      {:ok, approved_specialist2} =
        ExternalSpecialist.set_approval_status(approved_specialist2, "VERIFIED")

      waiting_specialist1 = insert_verified_external_with_onboarding_completed()
      waiting_specialist2 = insert_verified_external_with_onboarding_completed()

      [
        approved_specialist1: approved_specialist1,
        rejected_specialist: rejected_specialist,
        approved_specialist2: approved_specialist2,
        waiting_specialist1: waiting_specialist1,
        waiting_specialist2: waiting_specialist2
      ]
    end

    test "returns specialists waiting for approvals at the top by join timestamp and
      then rest sorted by approval_status_update_at",
         externals do
      assert {:ok, fetched_externals, nil} = ExternalSpecialist.fetch(%{})

      expected_order = [
        externals.waiting_specialist2.id,
        externals.waiting_specialist1.id,
        externals.approved_specialist2.id,
        externals.rejected_specialist.id,
        externals.approved_specialist1.id
      ]

      assert expected_order == Enum.map(fetched_externals, & &1.id)
    end

    test "does not return specialist which did not finish onboarding yet" do
      first_not_onbarded =
        Authentication.Factory.insert(:not_onboarded_specialist, type: "EXTERNAL")

      second_not_onbarded =
        Authentication.Factory.insert(:not_onboarded_specialist, type: "EXTERNAL")

      assert {:ok, fetched_externals, nil} = ExternalSpecialist.fetch(%{})

      assert nil == Enum.find(fetched_externals, fn s -> s.id == first_not_onbarded.id end)
      assert nil == Enum.find(fetched_externals, fn s -> s.id == second_not_onbarded.id end)
    end

    test "generates and uses next_token for pagination if next record has approval_status WAITING",
         externals do
      assert {:ok, [_fetched], next_token} =
               ExternalSpecialist.fetch(%{
                 "limit" => "1"
               })

      assert {:ok, fetched_externals, nil} =
               ExternalSpecialist.fetch(%{"next_token" => next_token})

      expected_order = [
        externals.waiting_specialist1.id,
        externals.approved_specialist2.id,
        externals.rejected_specialist.id,
        externals.approved_specialist1.id
      ]

      assert expected_order == Enum.map(fetched_externals, & &1.id)
    end

    test "generates and uses next_token for pagination if next record has
      approval_status other than WAITING",
         externals do
      assert {:ok, [_fetched1, _fetched2, _fetched3], next_token} =
               ExternalSpecialist.fetch(%{
                 "limit" => "3"
               })

      assert {:ok, fetched_externals, nil} =
               ExternalSpecialist.fetch(%{"next_token" => next_token})

      expected_order = [
        externals.rejected_specialist.id,
        externals.approved_specialist1.id
      ]

      assert expected_order == Enum.map(fetched_externals, & &1.id)
    end

    test "filter result by provided data in filter param", externals do
      assert {:ok, [fetched_external], nil} =
               ExternalSpecialist.fetch(%{"filter" => "first_name"})

      assert fetched_external.id == externals.approved_specialist1.id
    end

    test "returns specialists with given categories", externals do
      category_id1 = get_medical_category_id(externals.approved_specialist1.id)
      category_id2 = get_medical_category_id(externals.approved_specialist2.id)

      categories_ids = "#{category_id1},#{category_id2}"

      params = %{"categories_ids" => categories_ids}
      assert {:ok, fetched_externals, nil} = ExternalSpecialist.fetch(params)

      expected_order = [
        externals.approved_specialist2.id,
        externals.approved_specialist1.id
      ]

      assert expected_order == Enum.map(fetched_externals, & &1.id)
    end
  end

  describe "fetch/1 - with sorting" do
    test "sorts by first_name (ASC)" do
      specialist_c = insert_verified_external_with_onboarding_completed(first_name: "C")
      specialist_b = insert_verified_external_with_onboarding_completed(first_name: "B")
      specialist_a = insert_verified_external_with_onboarding_completed(first_name: "A")

      params = %{"sort_by" => "first_name", "order" => "asc"}

      {:ok, fetched, nil} = ExternalSpecialist.fetch(params)

      expected_order = [specialist_a.id, specialist_b.id, specialist_c.id]
      assert Enum.map(fetched, & &1.id) == expected_order
    end

    test "sorts by first_name (DESC)" do
      specialist_c = insert_verified_external_with_onboarding_completed(first_name: "C")
      specialist_b = insert_verified_external_with_onboarding_completed(first_name: "B")
      specialist_a = insert_verified_external_with_onboarding_completed(first_name: "A")

      params = %{"sort_by" => "first_name", "order" => "desc"}

      {:ok, fetched, nil} = ExternalSpecialist.fetch(params)

      expected_order = [specialist_c.id, specialist_b.id, specialist_a.id]
      assert Enum.map(fetched, & &1.id) == expected_order
    end

    test "sorts by inserted_at (ASC)" do
      specialist_c = insert_verified_external_with_onboarding_completed()
      specialist_b = insert_verified_external_with_onboarding_completed()
      specialist_a = insert_verified_external_with_onboarding_completed()

      params = %{"sort_by" => "joined_at", "order" => "asc"}

      {:ok, fetched, nil} = ExternalSpecialist.fetch(params)

      expected_order = [specialist_c.id, specialist_b.id, specialist_a.id]
      assert Enum.map(fetched, & &1.id) == expected_order
    end

    test "sorts by inserted_at (DESC)" do
      specialist_c = insert_verified_external_with_onboarding_completed()
      specialist_b = insert_verified_external_with_onboarding_completed()
      specialist_a = insert_verified_external_with_onboarding_completed()

      params = %{"sort_by" => "joined_at", "order" => "desc"}

      {:ok, fetched, nil} = ExternalSpecialist.fetch(params)

      expected_order = [specialist_a.id, specialist_b.id, specialist_c.id]
      assert Enum.map(fetched, & &1.id) == expected_order
    end

    test "pagination works (ASC)" do
      specialist_c = insert_verified_external_with_onboarding_completed(first_name: "C")
      specialist_b = insert_verified_external_with_onboarding_completed(first_name: "B")
      specialist_a = insert_verified_external_with_onboarding_completed(first_name: "A")

      params = %{"sort_by" => "first_name", "order" => "asc", "next_token" => "", "limit" => "2"}

      {:ok, fetched, next_token} = ExternalSpecialist.fetch(params)
      expected_order = [specialist_a.id, specialist_b.id]
      assert Enum.map(fetched, & &1.id) == expected_order

      params = %{params | "next_token" => next_token}
      {:ok, fetched, nil} = ExternalSpecialist.fetch(params)
      expected_order = [specialist_c.id]
      assert Enum.map(fetched, & &1.id) == expected_order
    end

    test "pagination works (DESC)" do
      specialist_c = insert_verified_external_with_onboarding_completed(first_name: "C")
      specialist_b = insert_verified_external_with_onboarding_completed(first_name: "B")
      specialist_a = insert_verified_external_with_onboarding_completed(first_name: "A")

      params = %{"sort_by" => "first_name", "order" => "desc", "next_token" => "", "limit" => "2"}

      {:ok, fetched, next_token} = ExternalSpecialist.fetch(params)
      expected_order = [specialist_c.id, specialist_b.id]
      assert Enum.map(fetched, & &1.id) == expected_order

      params = %{params | "next_token" => next_token}
      {:ok, fetched, nil} = ExternalSpecialist.fetch(params)
      expected_order = [specialist_a.id]
      assert Enum.map(fetched, & &1.id) == expected_order
    end
  end

  describe "set_approval_status/1" do
    test "sets approval status and approval_status_updated_at when params are valid" do
      specialist = insert_verified_external_with_onboarding_completed()

      {:ok, specialist} = ExternalSpecialist.fetch_by_id(specialist.id)
      assert {:ok, specialist} = ExternalSpecialist.set_approval_status(specialist, "VERIFIED")

      assert specialist.approval_status == "VERIFIED"
      refute is_nil(specialist.approval_status_updated_at)
    end

    test "returns {:error, changeset} when status is invalid" do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")
      {:ok, specialist} = ExternalSpecialist.fetch_by_id(specialist.id)

      assert {:error, %Ecto.Changeset{}} =
               ExternalSpecialist.set_approval_status(specialist, "INVALID_STATUS")
    end
  end

  defp insert_verified_external_with_onboarding_completed(basic_info_params \\ []) do
    specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

    basic_info_params = Keyword.merge([specialist_id: specialist.id], basic_info_params)
    _basic_info = SpecialistProfile.Factory.insert(:basic_info, basic_info_params)
    _location = SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)

    medical_category = SpecialistProfile.Factory.insert(:medical_category)
    SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

    _medical_credentials =
      SpecialistProfile.Factory.insert(:medical_credentials, specialist_id: specialist.id)

    {:ok, specialist} = ExternalSpecialist.fetch_by_id(specialist.id)

    specialist
  end

  defp get_medical_category_id(specialist_id) do
    {:ok, [first_medical_category | _]} =
      SpecialistProfile.fetch_medical_categories(specialist_id)

    first_medical_category.id
  end
end
