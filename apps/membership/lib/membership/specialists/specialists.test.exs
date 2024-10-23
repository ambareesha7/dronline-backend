defmodule Membership.SpecialistsTest do
  use Postgres.DataCase, async: true

  describe "fetch_by_id/1" do
    test "returns {:ok, specialists} with basic info and location included if they exist" do
      specialist = Authentication.Factory.insert(:verified_specialist)

      SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      assert {:ok, returned_specialist} = Membership.Specialists.fetch_by_id(specialist.id)

      refute is_nil(returned_specialist.first_name)
      refute is_nil(returned_specialist.street)
    end

    test "returns {:error, :not_found} when basic info or location for specialist doesn't exist" do
      specialist = Authentication.Factory.insert(:verified_specialist)

      assert {:error, :not_found} = Membership.Specialists.fetch_by_id(specialist.id)
    end

    test "returns {:error, :not_found} if id is invalid" do
      assert {:error, :not_found} = Membership.Specialists.fetch_by_id(0)
    end
  end
end
