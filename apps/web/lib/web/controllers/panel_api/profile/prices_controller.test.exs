defmodule Web.PanelApi.Profile.PricesControllerTest do
  use Web.ConnCase, async: true

  alias Postgres.Repo
  alias Proto.SpecialistProfile.GetPricesResponse
  alias Proto.SpecialistProfile.UpdatePricesRequest
  alias Proto.SpecialistProfile.UpdatePricesResponse

  alias Proto.SpecialistProfile.CategoryPricesRequest
  alias Proto.SpecialistProfile.CategoryPricesResponse

  describe "GET show" do
    setup [:authenticate_gp]

    test "returns empty prices when it doesn't exist, marks pricing tables as seen", %{conn: conn} do
      conn = get(conn, panel_profile_prices_path(conn, :index))

      assert %GetPricesResponse{categories_prices: []} =
               proto_response(conn, 200, GetPricesResponse)

      assert %{has_seen_pricing_tables: true} = Repo.one(SpecialistProfile.Status)
    end

    test "returns prices when it exists, marks pricing tables as seen", %{
      conn: conn,
      current_gp: current_gp
    } do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "medical_category")

      SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      _prices =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: current_gp.id,
          medical_category_id: medical_category.id,
          price_minutes_15: 199
        )

      _other_specialist_prices =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: specialist.id,
          medical_category_id: medical_category.id,
          price_minutes_15: 299
        )

      conn = get(conn, panel_profile_prices_path(conn, :index))

      assert %GetPricesResponse{
               categories_prices: [%CategoryPricesResponse{price_minutes_15: 199}]
             } = proto_response(conn, 200, GetPricesResponse)

      assert %{has_seen_pricing_tables: true} = Repo.get(SpecialistProfile.Status, current_gp.id)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_gp]

    test "updates specialist prices", %{conn: conn} do
      medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "medical_category")

      proto =
        %{
          category_prices:
            CategoryPricesRequest.new(
              price_minutes_15: 9,
              price_minutes_30: 99,
              price_minutes_45: 999,
              price_minutes_60: 9_999,
              price_second_opinion: 99_999,
              price_in_office: 1000,
              currency: "AED",
              currency_in_office: "AED",
              medical_category_id: medical_category.id
            )
        }
        |> UpdatePricesRequest.new()
        |> UpdatePricesRequest.encode()

      conn = put(conn, panel_profile_prices_path(conn, :update), proto)

      assert %UpdatePricesResponse{
               category_prices: %CategoryPricesResponse{
                 price_minutes_15: 9,
                 prices_enabled: true
               }
             } = proto_response(conn, 200, UpdatePricesResponse)
    end

    test "returns 422 if price_minutes_15 and price_in_office is set to 0", %{conn: conn} do
      medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "medical_category")

      proto =
        %{
          category_prices:
            CategoryPricesRequest.new(
              price_minutes_15: 0,
              price_minutes_30: 10,
              price_minutes_45: 10,
              price_minutes_60: 10,
              price_second_opinion: 10,
              price_in_office: 0,
              currency: "AED",
              currency_in_office: "AED",
              medical_category_id: medical_category.id
            )
        }
        |> UpdatePricesRequest.new()
        |> UpdatePricesRequest.encode()

      conn = put(conn, panel_profile_prices_path(conn, :update), proto)

      assert proto_response(conn, 422, Proto.Errors.ErrorResponse)
    end
  end
end
