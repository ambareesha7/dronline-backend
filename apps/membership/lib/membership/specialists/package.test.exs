defmodule Membership.Specialists.PackageTest do
  use Postgres.DataCase, async: true

  describe "fetch_active_package_type/1" do
    test "returns correct type" do
      specialist = Authentication.Factory.insert(:verified_specialist)

      _ =
        Membership.Factory.insert(:accepted_subscription,
          specialist_id: specialist.id,
          type: "PLATINUM"
        )

      assert {:ok, "PLATINUM"} = Membership.Specialists.Package.fetch_active_type(specialist.id)
    end
  end
end
