defmodule Web.PanelApi.Profile.V2.EducationControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfileV2.EducationEntryV2
  alias Proto.SpecialistProfileV2.GetEducationResponseV2
  alias Proto.SpecialistProfileV2.UpdateEducationRequestV2
  alias Proto.SpecialistProfileV2.UpdateEducationResponseV2

  describe "GET show" do
    setup [:authenticate_gp]

    test "returns list of education records", %{conn: conn, current_gp: current_gp} do
      _bio = SpecialistProfile.Factory.insert(:bio, specialist_id: current_gp.id)

      conn = get(conn, panel_profile_v2_education_path(conn, :show))

      assert %GetEducationResponseV2{education: [%EducationEntryV2{} = _education_entry]} =
               proto_response(conn, 200, GetEducationResponseV2)
    end

    test "returns empty list if specialist hasn't got any education entries", %{conn: conn} do
      conn = get(conn, panel_profile_v2_education_path(conn, :show))

      assert %GetEducationResponseV2{education: []} =
               proto_response(conn, 200, GetEducationResponseV2)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_gp]

    test "success", %{conn: conn, current_gp: current_gp} do
      _bio =
        SpecialistProfile.Factory.insert(:bio,
          specialist_id: current_gp.id,
          description: "Test Bio"
        )

      proto =
        %{
          education: [
            EducationEntryV2.new(
              school: "Giga szkoła",
              field_of_study: "Macroeconomy",
              degree: "PHD",
              start_year: 2015,
              end_year: 2023
            ),
            EducationEntryV2.new(
              school: "Giga szkoła 2",
              field_of_study: "Pharma",
              degree: "PHD",
              start_year: 2010,
              end_year: 2015
            )
          ]
        }
        |> UpdateEducationRequestV2.new()
        |> UpdateEducationRequestV2.encode()

      conn = put(conn, panel_profile_v2_education_path(conn, :update), proto)

      assert %UpdateEducationResponseV2{education: [%EducationEntryV2{}, %EducationEntryV2{}]} =
               proto_response(conn, 200, UpdateEducationResponseV2)
    end
  end
end
