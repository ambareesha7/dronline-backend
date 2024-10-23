defmodule Web.Api.InsuranceProvidersControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Insurance.GetProvidersResponse

  describe "GET index" do
    test "succeeds", %{conn: conn} do
      country_us = Postgres.Factory.insert(:country, id: "us", name: "USA")
      country_fr = Postgres.Factory.insert(:country, id: "fr", name: "France")

      _us_provider =
        Insurance.Factory.insert(:provider, %{
          name: "provider_name_us",
          country_id: country_us.id
        })

      _fr_provider =
        Insurance.Factory.insert(:provider, %{
          name: "provider_name_fr",
          country_id: country_fr.id
        })

      conn = get(conn, insurance_providers_path(conn, :index), %{"country" => "us"})

      assert %GetProvidersResponse{
               providers: [
                 %{
                   name: "provider_name_us"
                 }
               ]
             } = proto_response(conn, 200, GetProvidersResponse)
    end
  end
end
