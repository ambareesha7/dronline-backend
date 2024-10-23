defmodule Insurance.ProvidersTest do
  use Postgres.DataCase, async: true

  alias Insurance.Providers

  describe "all_for_country/1" do
    test "returns matching providers" do
      country =
        Postgres.Factory.insert(:country, %{
          iso2_code: "us"
        })

      _provider =
        Insurance.Factory.insert(:provider, %{
          country_id: country.id
        })

      assert {:ok, [_]} = Providers.all_for_country("us")
      assert {:ok, []} = Providers.all_for_country("ua")
    end
  end
end
