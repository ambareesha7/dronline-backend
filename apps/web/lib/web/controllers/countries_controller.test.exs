defmodule Web.PublicApi.CountriesControllerTest do
  use Web.ConnCase, async: true

  test "index/2 returns list of all countries", %{conn: conn} do
    Postgres.Factory.insert(:country, %{
      id: "ua",
      name: "Ukraine",
      dial_code: "380"
    })

    conn = get(conn, "/public_api/countries")

    assert %Proto.Generics.Countries{
             countries: [
               %Proto.Generics.Country{
                 id: "ua",
                 name: "Ukraine",
                 dial_code: "380"
               }
             ]
           } = proto_response(conn, 200, Proto.Generics.Countries)
  end
end
