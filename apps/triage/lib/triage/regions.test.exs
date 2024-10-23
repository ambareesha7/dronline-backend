defmodule Triage.RegionsTest do
  use Postgres.DataCase, async: true

  alias Triage.Regions

  describe "determine_region/1" do
    test "creates region from country and city" do
      patient_location_address = %{country: "United Arab Emirates", city: "Dubai"}

      assert {:ok, region} = Regions.determine_region(patient_location_address)
      assert region == "united-arab-emirates-dubai"
    end
  end
end
