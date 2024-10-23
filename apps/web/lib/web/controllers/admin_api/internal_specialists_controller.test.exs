defmodule Web.AdminApi.InternalSpecialistsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.AdminPanel.CreateInternalSpecialistRequest
  alias Proto.AdminPanel.CreateInternalSpecialistResponse
  alias Proto.AdminPanel.GetInternalSpecialistResponse
  alias Proto.AdminPanel.GetInternalSpecialistsResponse

  describe "POST create" do
    setup [:authenticate_admin, :proto_content]

    test "succeeds", %{conn: conn} do
      proto =
        %{
          internal_specialist_account:
            Proto.AdminPanel.InternalSpecialistAccount.new(%{
              email: "email@example.com",
              password: "Password1!",
              type: :NURSE |> Proto.AdminPanel.InternalSpecialistAccount.Type.value()
            })
        }
        |> CreateInternalSpecialistRequest.new()
        |> CreateInternalSpecialistRequest.encode()

      conn = post(conn, admin_internal_specialists_path(conn, :create), proto)

      assert %CreateInternalSpecialistResponse{
               internal_specialist_account: internal_specialist_account
             } = proto_response(conn, 200, CreateInternalSpecialistResponse)

      assert internal_specialist_account.email == "email@example.com"
    end
  end

  describe "GET index" do
    setup [:authenticate_admin]

    test "succeeds without sorting", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      medical_category = SpecialistProfile.Factory.insert(:medical_category)
      _ = SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      conn = get(conn, admin_internal_specialists_path(conn, :index))

      assert %GetInternalSpecialistsResponse{internal_specialists: [member], next_token: ""} =
               proto_response(conn, 200, GetInternalSpecialistsResponse)

      assert member.id == specialist.id
      assert member.email == specialist.email
    end

    test "succeeds with sorting", %{conn: conn} do
      specialists =
        for _i <- 1..5, into: %{} do
          specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
          basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

          {basic_info.first_name, specialist}
        end

      ordered_first_names = specialists |> Map.keys() |> Enum.sort()

      conn =
        get(conn, admin_internal_specialists_path(conn, :index),
          sort_by: "first_name",
          order: "asc",
          limit: "3"
        )

      assert %GetInternalSpecialistsResponse{
               internal_specialists: [_specialist0, _specialist1, _specialist2],
               next_token: next_token
             } = proto_response(conn, 200, GetInternalSpecialistsResponse)

      {:ok, %{conn: conn}} = Web.ConnHelpers.authenticate_admin(%{})

      conn = get(conn, admin_internal_specialists_path(conn, :index), next_token: next_token)

      assert %GetInternalSpecialistsResponse{
               internal_specialists: [specialist3, _specialist4],
               next_token: ""
             } = proto_response(conn, 200, GetInternalSpecialistsResponse)

      assert specialist3.id == specialists[Enum.at(ordered_first_names, 3)].id
    end
  end

  describe "GET show" do
    setup [:authenticate_admin]

    test "succeeds", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")

      conn = get(conn, admin_internal_specialists_path(conn, :show, specialist.id))

      assert %GetInternalSpecialistResponse{type: type, created_at: created_at} =
               proto_response(conn, 200, GetInternalSpecialistResponse)

      assert type == :NURSE
      assert created_at.timestamp == specialist.inserted_at |> Timex.to_unix()
    end
  end
end
