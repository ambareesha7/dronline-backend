defmodule Web.AdminApi.ExternalSpecialistsTest do
  use Web.ConnCase, async: true

  alias Proto.AdminPanel.GetExternalSpecialistResponse
  alias Proto.AdminPanel.GetExternalSpecialistsResponse

  describe "GET index" do
    setup [:authenticate_admin]

    test "succeeds", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      medical_category = SpecialistProfile.Factory.insert(:medical_category)
      _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      conn = get(conn, admin_external_specialists_path(conn, :index))

      assert %GetExternalSpecialistsResponse{
               external_specialists: [fetched_specialist],
               next_token: ""
             } = proto_response(conn, 200, GetExternalSpecialistsResponse)

      assert fetched_specialist.id == specialist.id
      assert length(fetched_specialist.medical_categories) == 1
    end
  end

  describe "GET show" do
    setup [:authenticate_admin]

    test "succeeds", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      conn = get(conn, admin_external_specialists_path(conn, :show, specialist.id))

      assert %GetExternalSpecialistResponse{joined_at: joined_at} =
               proto_response(conn, 200, GetExternalSpecialistResponse)

      assert joined_at.timestamp == specialist.inserted_at |> Timex.to_unix()
    end
  end
end
