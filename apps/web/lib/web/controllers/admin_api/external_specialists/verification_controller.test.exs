defmodule Web.AdminApi.ExternalSpecialists.VerificationControllerTest do
  use Web.ConnCase

  alias Proto.AdminPanel.VerifyExternalSpecialistRequest

  describe "POST verify" do
    setup [:authenticate_admin, :proto_content]

    test "verifies a specialist if one has completed onboarding process", %{conn: conn} do
      specialist = Authentication.Factory.insert(:verified_specialist, type: "EXTERNAL")
      SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      _ = SpecialistProfile.Factory.insert(:location, specialist_id: specialist.id)
      medical_category = SpecialistProfile.Factory.insert(:medical_category)

      {:ok, [specialist_medical_category]} =
        SpecialistProfile.update_medical_categories([medical_category.id], specialist.id)

      _ = SpecialistProfile.Factory.insert(:medical_credentials, specialist_id: specialist.id)

      _ =
        SpecialistProfile.Factory.insert(:prices,
          specialist_id: specialist.id,
          medical_category_id: specialist_medical_category.id
        )

      proto =
        %{
          status: :VERIFIED |> VerifyExternalSpecialistRequest.Status.value()
        }
        |> VerifyExternalSpecialistRequest.new()
        |> VerifyExternalSpecialistRequest.encode()

      conn =
        post(
          conn,
          admin_external_specialists_verification_path(conn, :verify, specialist.id),
          proto
        )

      assert response(conn, 200)
    end

    test "returns 422 error when onboarding is not completed", %{conn: conn} do
      specialist =
        Authentication.Factory.insert(:not_onboarded_verified_specialist, type: "EXTERNAL")

      proto =
        %{
          status: :VERIFIED |> VerifyExternalSpecialistRequest.Status.value()
        }
        |> VerifyExternalSpecialistRequest.new()
        |> VerifyExternalSpecialistRequest.encode()

      conn =
        post(
          conn,
          admin_external_specialists_verification_path(conn, :verify, specialist.id),
          proto
        )

      assert response(conn, 422)
    end
  end
end
