defmodule Web.AdminApi.InternalSpecialists.MedicalCredentialsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetMedicalCredentialsResponse
  alias Proto.SpecialistProfile.UpdateMedicalCredentialsRequest
  alias Proto.SpecialistProfile.UpdateMedicalCredentialsResponse

  alias Proto.SpecialistProfile.MedicalCredentials

  describe "GET show" do
    setup [:authenticate_admin]

    test "success when medical_credentials doesn't exist", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      conn =
        get(conn, admin_internal_specialists_medical_credentials_path(conn, :show, specialist.id))

      assert %GetMedicalCredentialsResponse{medical_credentials: %MedicalCredentials{}} =
               proto_response(conn, 200, GetMedicalCredentialsResponse)
    end

    test "success when medical_credentials exists", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      _medical_credentials =
        SpecialistProfile.Factory.insert(:medical_credentials,
          specialist_id: specialist.id,
          dea_number_url: "dea_url"
        )

      conn =
        get(conn, admin_internal_specialists_medical_credentials_path(conn, :show, specialist.id))

      assert %GetMedicalCredentialsResponse{
               medical_credentials: %MedicalCredentials{dea_number_url: "dea_url"}
             } = proto_response(conn, 200, GetMedicalCredentialsResponse)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_admin]

    test "success when medical_credentials doesn't exist", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      proto =
        %{
          medical_credentials:
            MedicalCredentials.new(
              dea_number_url: "random_url",
              dea_number_expiry_date: Proto.Generics.DateTime.new(),
              board_certification_url: "random_url",
              board_certification_expiry_date: Proto.Generics.DateTime.new(),
              current_state_license_number_url: "random_url",
              current_state_license_number_expiry_date: Proto.Generics.DateTime.new()
            )
        }
        |> UpdateMedicalCredentialsRequest.new()
        |> UpdateMedicalCredentialsRequest.encode()

      conn =
        put(
          conn,
          admin_internal_specialists_medical_credentials_path(conn, :update, specialist.id),
          proto
        )

      assert %UpdateMedicalCredentialsResponse{
               medical_credentials: %MedicalCredentials{dea_number_url: "random_url"}
             } = proto_response(conn, 200, UpdateMedicalCredentialsResponse)
    end

    test "success when medical_credentials exist", %{
      conn: conn
    } do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")

      _medical_credentials =
        SpecialistProfile.Factory.insert(:medical_credentials,
          specialist_id: specialist.id
        )

      proto =
        %{
          medical_credentials:
            MedicalCredentials.new(
              dea_number_url: "random_url",
              dea_number_expiry_date: Proto.Generics.DateTime.new(),
              board_certification_url: "random_url",
              board_certification_expiry_date: Proto.Generics.DateTime.new(),
              current_state_license_number_url: "random_url",
              current_state_license_number_expiry_date: Proto.Generics.DateTime.new()
            )
        }
        |> UpdateMedicalCredentialsRequest.new()
        |> UpdateMedicalCredentialsRequest.encode()

      conn =
        put(
          conn,
          admin_internal_specialists_medical_credentials_path(conn, :update, specialist.id),
          proto
        )

      assert %UpdateMedicalCredentialsResponse{
               medical_credentials: %MedicalCredentials{dea_number_url: "random_url"}
             } = proto_response(conn, 200, UpdateMedicalCredentialsResponse)
    end
  end
end
