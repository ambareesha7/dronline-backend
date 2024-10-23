defmodule Web.PanelApi.Profile.V2.InsuranceProvidersControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfileV2.GetInsuranceProvidersV2
  alias Proto.SpecialistProfileV2.InsuranceProvidersEntryV2
  alias Proto.SpecialistProfileV2.UpdateInsuranceProvidersRequestV2
  alias Proto.SpecialistProfileV2.UpdateInsuranceProvidersResponseV2

  describe "GET show" do
    setup [:authenticate_gp]

    test "returns list of insurance providers records", %{conn: conn, current_gp: current_gp} do
      country = Postgres.Factory.insert(:country, [])

      insurance_provider1 =
        Insurance.Factory.insert(:provider, name: "provider_name1", country_id: country.id)

      insurance_provider2 =
        Insurance.Factory.insert(:provider, name: "provider_name2", country_id: country.id)

      SpecialistProfile.Specialist.update_insurance_providers(
        current_gp.id,
        [
          insurance_provider1.id,
          insurance_provider2.id
        ]
      )

      conn = get(conn, panel_profile_v2_insurance_providers_path(conn, :show))

      assert %GetInsuranceProvidersV2{
               insurance_providers: [
                 %InsuranceProvidersEntryV2{name: "provider_name1"},
                 %InsuranceProvidersEntryV2{name: "provider_name2"}
               ]
             } = proto_response(conn, 200, GetInsuranceProvidersV2)
    end

    test "returns empty list if specialist hasn't got any insurance providers records", %{
      conn: conn
    } do
      conn = get(conn, panel_profile_v2_insurance_providers_path(conn, :show))

      assert %GetInsuranceProvidersV2{insurance_providers: []} =
               proto_response(conn, 200, GetInsuranceProvidersV2)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_gp]

    test "success", %{conn: conn} do
      country = Postgres.Factory.insert(:country, [])

      insurance_provider =
        Insurance.Factory.insert(:provider, name: "provider_name1", country_id: country.id)

      proto =
        %{
          insurance_providers: [
            InsuranceProvidersEntryV2.new(
              id: insurance_provider.id,
              name: insurance_provider.name,
              country_id: insurance_provider.country_id
            )
          ]
        }
        |> UpdateInsuranceProvidersRequestV2.new()
        |> UpdateInsuranceProvidersRequestV2.encode()

      conn = put(conn, panel_profile_v2_insurance_providers_path(conn, :update), proto)

      assert %UpdateInsuranceProvidersResponseV2{
               insurance_providers: [%InsuranceProvidersEntryV2{name: "provider_name1"}]
             } = proto_response(conn, 200, UpdateInsuranceProvidersResponseV2)
    end
  end
end
