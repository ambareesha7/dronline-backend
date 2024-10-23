defmodule Web.Api.Profile.PricesControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.CategoryPricesResponse
  alias Proto.SpecialistProfile.GetPricesResponse

  describe "GET show" do
    setup [:authenticate_patient]

    test "returns empty list, doesn't mark pricing tables as seen", %{
      conn: conn
    } do
      specialist = Authentication.Factory.insert(:specialist)

      conn = get(conn, specialists_prices_path(conn, :index, specialist.id))

      assert %GetPricesResponse{categories_prices: []} =
               proto_response(conn, 200, GetPricesResponse)

      assert %{has_seen_pricing_tables: false} = Postgres.Repo.one(SpecialistProfile.Status)
    end

    test "returns prices, doesn't mark pricing tables as seen", %{
      conn: conn
    } do
      specialist = Authentication.Factory.insert(:specialist)

      medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "medical_category")

      _prices =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: specialist.id,
          medical_category_id: medical_category.id,
          price_minutes_15: 199
        )

      conn = get(conn, specialists_prices_path(conn, :index, specialist.id))

      assert %GetPricesResponse{
               categories_prices: [%CategoryPricesResponse{price_minutes_15: 199}]
             } = proto_response(conn, 200, GetPricesResponse)

      assert %{has_seen_pricing_tables: false} = Postgres.Repo.one(SpecialistProfile.Status)
    end
  end
end
