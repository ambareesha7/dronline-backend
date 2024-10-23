defmodule Web.PanelApi.Profile.V2.WorkExperienceControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfileV2.GetWorkExperienceV2
  alias Proto.SpecialistProfileV2.UpdateWorkExperienceRequestV2
  alias Proto.SpecialistProfileV2.UpdateWorkExperienceResponseV2
  alias Proto.SpecialistProfileV2.WorkExperienceEntryV2

  describe "GET show" do
    setup [:authenticate_gp]

    test "returns list of work experience records", %{conn: conn, current_gp: current_gp} do
      _bio = SpecialistProfile.Factory.insert(:bio, specialist_id: current_gp.id)

      conn = get(conn, panel_profile_v2_work_experience_path(conn, :show))

      assert %GetWorkExperienceV2{work_experience: [%WorkExperienceEntryV2{}]} =
               proto_response(conn, 200, GetWorkExperienceV2)
    end

    test "returns empty list if specialist hasn't got any education entries", %{conn: conn} do
      conn = get(conn, panel_profile_v2_work_experience_path(conn, :show))

      assert %GetWorkExperienceV2{work_experience: []} =
               proto_response(conn, 200, GetWorkExperienceV2)
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
          work_experience: [
            WorkExperienceEntryV2.new(
              institution: "Giga Institution 1",
              position: "Robak",
              start_year: 2015,
              end_year: 2018
            ),
            WorkExperienceEntryV2.new(
              institution: "Giga Institution 2",
              position: "Robak",
              start_year: 2018,
              end_year: 2023
            )
          ]
        }
        |> UpdateWorkExperienceRequestV2.new()
        |> UpdateWorkExperienceRequestV2.encode()

      conn = put(conn, panel_profile_v2_work_experience_path(conn, :update), proto)

      assert %UpdateWorkExperienceResponseV2{
               work_experience: [%WorkExperienceEntryV2{}, %WorkExperienceEntryV2{}]
             } = proto_response(conn, 200, UpdateWorkExperienceResponseV2)
    end
  end
end
