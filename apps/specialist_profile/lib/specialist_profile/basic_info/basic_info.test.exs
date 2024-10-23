defmodule SpecialistProfile.BasicInfoTest do
  use Postgres.DataCase, async: true

  alias SpecialistProfile.BasicInfo
  alias SpecialistProfile.Status

  describe "fetch_by_specialist_id/1" do
    test "returns basic info when specialist_id is valid" do
      specialist = Authentication.Factory.insert(:specialist)

      basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist.id,
          first_name: "Jan"
        )

      {:ok, fetched} = BasicInfo.fetch_by_specialist_id(specialist.id)

      assert fetched.first_name == basic_info.first_name
    end

    test "returns empty basic info when specialist_id is invalid" do
      {:ok, %BasicInfo{id: nil}} = BasicInfo.fetch_by_specialist_id(0)
    end
  end

  describe "update/2" do
    test "creates new basic info when it doesn't exist" do
      specialist = Authentication.Factory.insert(:specialist)

      params = %{
        title: "MR",
        gender: "MALE",
        first_name: "FN",
        last_name: "LN",
        birth_date: ~D[2018-11-13],
        image_url: "http://example.com/image/jpg",
        phone_number: "random_number"
      }

      {:ok, %{first_name: "FN"}} = BasicInfo.update(params, specialist.id)
    end

    test "updates basic info when it exists" do
      specialist = Authentication.Factory.insert(:specialist)

      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info,
          specialist_id: specialist.id,
          first_name: "FN"
        )

      params = %{first_name: "NFN"}

      {:ok, %{first_name: "NFN"}} = BasicInfo.update(params, specialist.id)
    end

    test "updates basic info and sets onboarding as completed for internal specialists" do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      params = %{
        title: "MR",
        gender: "MALE",
        first_name: "FN",
        last_name: "LN",
        birth_date: ~D[1988-11-13],
        image_url: "http://example.com/image/jpg",
        phone_number: "random_number"
      }

      assert {:ok, basic_info} = BasicInfo.update(params, specialist.id)
      assert basic_info.first_name == params.first_name

      assert {:ok, %{onboarding_completed: true}} = Status.fetch_by_specialist_id(specialist.id)
    end

    test "returns changeset when params are invalid" do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      params = %{
        title: "MR",
        first_name: "FN",
        last_name: "LN",
        birth_date: ~D[1988-11-13],
        image_url: "http://example.com/image/jpg"
      }

      assert {:error, %Ecto.Changeset{}} = BasicInfo.update(params, specialist.id)
    end
  end
end
