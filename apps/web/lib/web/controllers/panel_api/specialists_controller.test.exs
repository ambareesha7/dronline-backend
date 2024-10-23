defmodule Web.PanelApi.SpecialistsControllerTest do
  use Web.ConnCase, async: true
  import Phoenix.ChannelTest

  alias Proto.SpecialistProfile.GetSpecialistsInCategoryResponse
  alias Proto.SpecialistProfile.GetSpecialistsResponse

  describe "GET index" do
    setup [:authenticate_gp]

    test "returns all specialists", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)
      _location = SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)

      conn = get(conn, panel_specialists_path(conn, :index))

      assert %GetSpecialistsResponse{
               specialists: [fetched_detailed_specialist],
               next_token: ""
             } = proto_response(conn, 200, GetSpecialistsResponse)

      assert fetched_detailed_specialist.specialist.id == specialist.id
    end
  end

  describe "GET index online" do
    setup [:authenticate_gp]

    test "returns online specialists", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)
      _location = SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)
      :ok = join_doctor_channel(specialist.id)

      conn = get(conn, panel_specialists_path(conn, :index_online))

      assert %GetSpecialistsResponse{
               specialists: [fetched_detailed_specialist],
               next_token: ""
             } = proto_response(conn, 200, GetSpecialistsResponse)

      assert fetched_detailed_specialist.specialist.id == specialist.id
    end
  end

  describe "GET category" do
    setup [:authenticate_gp]

    test "returns all specialists with given category", %{conn: conn} do
      category = SpecialistProfile.Factory.insert(:medical_category)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      {:ok, _medical_categories} =
        SpecialistProfile.Specialist.update_categories(
          [
            category.id
          ],
          specialist.id
        )

      conn = get(conn, panel_specialists_path(conn, :category, category.id))

      assert %GetSpecialistsInCategoryResponse{
               specialists: [fetched_specialist]
             } = proto_response(conn, 200, GetSpecialistsInCategoryResponse)

      assert fetched_specialist.id == specialist.id
    end
  end

  defp join_doctor_channel(specialist_id) do
    doctor_socket =
      socket(Web.Socket, specialist_id, %{current_specialist_id: specialist_id, type: :EXTERNAL})

    {:ok, _, _doctor_socket} = subscribe_and_join(doctor_socket, Web.DoctorChannel, "doctor")

    :ok
  end
end
