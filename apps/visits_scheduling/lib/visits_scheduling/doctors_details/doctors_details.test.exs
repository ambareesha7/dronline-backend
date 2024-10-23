defmodule VisitsScheduling.DoctorsDetailsTest do
  use Postgres.DataCase, async: true

  alias VisitsScheduling.DoctorsDetails

  describe "fetch/1" do
    test "doesn't return nurses and gps" do
      specialist1 = Authentication.Factory.insert(:specialist, type: "GP")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist1.id)

      specialist2 = Authentication.Factory.insert(:specialist, type: "NURSE")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist2.id)

      assert {:ok, []} = DoctorsDetails.fetch([specialist1.id, specialist2.id])
    end

    test "returns internal and external doctors" do
      specialist1 = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist1.id)

      specialist2 = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist2.id)

      assert {:ok, [_, _]} = DoctorsDetails.fetch([specialist1.id, specialist2.id])
    end
  end
end
