defmodule SpecialistProfile.SpecialistsTest do
  use Postgres.DataCase, async: true

  setup do
    specialist1 = Authentication.Factory.insert(:verified_and_approved_external)

    specialist2 = Authentication.Factory.insert(:verified_and_approved_external)

    {:ok, specialist1: specialist1, specialist2: specialist2}
  end

  describe "fetch_all/1" do
    test "returns all approved doctors" do
      assert {:ok, [_specialist1, _specialist2], ""} =
               SpecialistProfile.Specialists.fetch_all(%{})
    end

    test "allows pagination", %{specialist1: specialist1, specialist2: specialist2} do
      assert {:ok, [], fetched_next_token} =
               SpecialistProfile.Specialists.fetch_all(%{"limit" => "0"})

      assert fetched_next_token == to_string(specialist1.id)

      assert {:ok, [fetched_specialist_id1, fetched_specialist_id2], ""} =
               SpecialistProfile.Specialists.fetch_all(%{
                 "next_token" => to_string(specialist1.id)
               })

      assert fetched_specialist_id1 == specialist1.id
      assert fetched_specialist_id2 == specialist2.id
    end

    test "filters by membership", %{specialist2: specialist} do
      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist.id,
        type: "PLATINUM"
      )

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.fetch_all(%{"membership" => "PLATINUM"})

      assert fetched_specialist_id == specialist.id
    end

    test "filters by search data", %{specialist2: specialist2} do
      SpecialistProfile.Factory.insert(:basic_info,
        specialist_id: specialist2.id,
        first_name: "Alfons"
      )

      SpecialistProfile.Factory.insert(:location,
        specialist_id: specialist2.id,
        country: "Poland"
      )

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.fetch_all(%{"filter" => "Poland"})

      assert fetched_specialist_id == specialist2.id

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.fetch_all(%{"filter" => "Alfons"})

      assert fetched_specialist_id == specialist2.id
    end
  end

  describe "fetch_online/2" do
    test "returns all online approved doctors", %{specialist2: specialist2} do
      online_ids = [specialist2.id]

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.fetch_online(%{}, online_ids)

      assert fetched_specialist_id == specialist2.id
    end

    test "allows pagination", %{specialist2: specialist2} do
      online_ids = [specialist2.id]

      assert {:ok, [], fetched_next_token} =
               SpecialistProfile.Specialists.fetch_online(%{"limit" => "0"}, online_ids)

      assert fetched_next_token == to_string(specialist2.id)

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.fetch_online(
                 %{"next_token" => to_string(specialist2.id)},
                 online_ids
               )

      assert fetched_specialist_id == specialist2.id
    end

    test "filters by membership", %{specialist1: specialist1, specialist2: specialist2} do
      online_ids = [specialist1.id, specialist2.id]

      Membership.Factory.insert(:accepted_subscription,
        specialist_id: specialist2.id,
        type: "PLATINUM"
      )

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.fetch_online(
                 %{"membership" => "PLATINUM"},
                 online_ids
               )

      assert fetched_specialist_id == specialist2.id
    end

    test "filters by search data", %{specialist1: specialist1, specialist2: specialist2} do
      online_ids = [specialist1.id, specialist2.id]

      SpecialistProfile.Factory.insert(:basic_info,
        specialist_id: specialist2.id,
        first_name: "Alfons"
      )

      SpecialistProfile.Factory.insert(:location,
        specialist_id: specialist2.id,
        country: "Poland"
      )

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.fetch_online(%{"filter" => "Poland"}, online_ids)

      assert fetched_specialist_id == specialist2.id

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.fetch_online(%{"filter" => "Alfons"}, online_ids)

      assert fetched_specialist_id == specialist2.id
    end
  end

  describe "search/1" do
    test "search by first name", %{specialist1: specialist1, specialist2: specialist2} do
      SpecialistProfile.Factory.insert(:basic_info,
        specialist_id: specialist1.id,
        first_name: "Alfons"
      )

      SpecialistProfile.Factory.insert(:basic_info,
        specialist_id: specialist2.id,
        first_name: "Andy"
      )

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.search(%{"filter" => "Alfons"})

      assert fetched_specialist_id == specialist1.id
    end

    test "search by last name", %{specialist1: specialist1, specialist2: specialist2} do
      SpecialistProfile.Factory.insert(:basic_info,
        specialist_id: specialist2.id,
        last_name: "Bernard"
      )

      SpecialistProfile.Factory.insert(:basic_info,
        specialist_id: specialist1.id,
        last_name: "Mucha"
      )

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.search(%{"filter" => "Mucha"})

      assert fetched_specialist_id == specialist1.id
    end

    test "search by medical category", %{specialist1: specialist1, specialist2: specialist2} do
      neurology = SpecialistProfile.Factory.insert(:medical_category, name: "Neurology")
      SpecialistProfile.update_medical_categories([neurology.id], specialist1.id)

      hepatology = SpecialistProfile.Factory.insert(:medical_category, name: "Hepatology")
      SpecialistProfile.update_medical_categories([hepatology.id], specialist2.id)

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.search(%{"filter" => "Neurology"})

      assert fetched_specialist_id == specialist1.id
    end

    test "search by country", %{specialist1: specialist1, specialist2: specialist2} do
      SpecialistProfile.Factory.insert(:location,
        specialist_id: specialist1.id,
        country: "Poland"
      )

      SpecialistProfile.Factory.insert(:location,
        specialist_id: specialist2.id,
        country: "France"
      )

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.search(%{"filter" => "Poland"})

      assert fetched_specialist_id == specialist1.id
    end

    test "search by city", %{specialist1: specialist1, specialist2: specialist2} do
      SpecialistProfile.Factory.insert(:location, specialist_id: specialist1.id, city: "Dubai")
      SpecialistProfile.Factory.insert(:location, specialist_id: specialist2.id, city: "Doha")

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.search(%{"filter" => "Dubai"})

      assert fetched_specialist_id == specialist1.id
    end

    test "search by mixed phrases", %{specialist1: specialist} do
      SpecialistProfile.Factory.insert(:basic_info,
        specialist_id: specialist.id,
        first_name: "Alfons",
        last_name: "Mucha"
      )

      SpecialistProfile.Factory.insert(:location,
        specialist_id: specialist.id,
        country: "UAE",
        city: "Dubai"
      )

      neurology = SpecialistProfile.Factory.insert(:medical_category, name: "Neurology")
      SpecialistProfile.update_medical_categories([neurology.id], specialist.id)

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.search(%{
                 "filter" => "Alfons Mucha UAE Dubai Neurology"
               })

      assert fetched_specialist_id == specialist.id

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.search(%{"filter" => "Neurology Dubai"})

      assert fetched_specialist_id == specialist.id
    end

    test "search doesn't find when words are incorrect", %{
      specialist1: specialist
    } do
      SpecialistProfile.Factory.insert(:basic_info,
        specialist_id: specialist.id,
        first_name: "Alfons",
        last_name: "Mucha"
      )

      SpecialistProfile.Factory.insert(:location,
        specialist_id: specialist.id,
        country: "UAE",
        city: "Dubai"
      )

      assert {:ok, [], ""} =
               SpecialistProfile.Specialists.search(%{
                 "filter" => "Dbai"
               })

      assert {:ok, [], ""} =
               SpecialistProfile.Specialists.search(%{
                 "filter" => "Alfns Mucha Poland Dubai"
               })
    end

    test "search is case insensitive", %{specialist1: specialist} do
      SpecialistProfile.Factory.insert(:basic_info,
        specialist_id: specialist.id,
        first_name: "Alfons",
        last_name: "Mucha"
      )

      SpecialistProfile.Factory.insert(:location,
        specialist_id: specialist.id,
        country: "Poland",
        city: "Poznan"
      )

      neurology = SpecialistProfile.Factory.insert(:medical_category, name: "Neurology")
      SpecialistProfile.update_medical_categories([neurology.id], specialist.id)

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.search(%{
                 "filter" => "alfons mucha poznan poland neurology"
               })

      assert fetched_specialist_id == specialist.id
    end

    test "search is sensitive for special characters", %{specialist1: specialist} do
      SpecialistProfile.Factory.insert(:location,
        specialist_id: specialist.id,
        country: "Poland",
        city: "Poznań"
      )

      assert {:ok, [], ""} =
               SpecialistProfile.Specialists.search(%{
                 "filter" => "Poznan"
               })

      assert {:ok, [], ""} =
               SpecialistProfile.Specialists.search(%{
                 "filter" => "Póland"
               })
    end

    test "search works for words prefixes", %{specialist1: specialist} do
      SpecialistProfile.Factory.insert(:basic_info,
        specialist_id: specialist.id,
        first_name: "Alfons",
        last_name: "Mucha"
      )

      SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id, country: "UAE")

      assert {:ok, [fetched_specialist_id], ""} =
               SpecialistProfile.Specialists.search(%{
                 "filter" => "alf much ua"
               })

      assert fetched_specialist_id == specialist.id
    end

    test "search doesn't work for words suffixes", %{
      specialist1: specialist
    } do
      SpecialistProfile.Factory.insert(:basic_info,
        specialist_id: specialist.id
      )

      SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id, country: "Poland")

      assert {:ok, [], ""} =
               SpecialistProfile.Specialists.search(%{
                 "filter" => "oland"
               })
    end

    test "search doesn't work for middle parts of the words", %{specialist1: specialist} do
      SpecialistProfile.Factory.insert(:basic_info,
        specialist_id: specialist.id
      )

      SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id, country: "Poland")

      assert {:ok, [], ""} =
               SpecialistProfile.Specialists.search(%{
                 "filter" => "ola"
               })
    end
  end
end
