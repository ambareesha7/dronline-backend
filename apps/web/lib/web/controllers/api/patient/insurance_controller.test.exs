defmodule Web.Api.Patient.InsuranceControllerTest do
  use Web.ConnCase, async: true

  alias Insurance.Accounts
  alias Proto.PatientProfile.DeleteInsuranceResponse
  alias Proto.PatientProfile.GetInsuranceResponse
  alias Proto.PatientProfile.UpdateInsuranceRequest
  alias Proto.PatientProfile.UpdateInsuranceResponse

  describe "GET show" do
    setup [:authenticate_patient]

    test "success when insurance doesn't exist", %{conn: conn} do
      conn = get(conn, patient_insurance_path(conn, :show))

      assert %GetInsuranceResponse{
               insurance: nil
             } = proto_response(conn, 200, GetInsuranceResponse)
    end

    test "success when insurance exist", %{conn: conn, current_patient: current_patient} do
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: current_patient.id)
      country = Postgres.Factory.insert(:country, [])

      provider =
        Insurance.Factory.insert(:provider, %{
          name: "provider_name",
          country_id: country.id
        })

      {:ok, _} =
        Accounts.set(
          %{
            provider_id: provider.id,
            member_id: "member_id"
          },
          current_patient.id
        )

      conn = get(conn, patient_insurance_path(conn, :show))

      assert %GetInsuranceResponse{
               insurance: %Proto.PatientProfile.Insurance{
                 member_id: "member_id",
                 provider: %Proto.Insurance.Provider{
                   id: _,
                   logo_url: _,
                   name: "provider_name"
                 }
               }
             } = proto_response(conn, 200, GetInsuranceResponse)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_patient]

    test "succeedes", %{conn: conn, current_patient: current_patient} do
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: current_patient.id)
      country = Postgres.Factory.insert(:country, [])

      provider =
        Insurance.Factory.insert(:provider, %{
          name: "provider_name",
          country_id: country.id
        })

      proto =
        %{
          provider_id: provider.id,
          member_id: "member_id"
        }
        |> UpdateInsuranceRequest.new()
        |> UpdateInsuranceRequest.encode()

      conn = put(conn, patient_insurance_path(conn, :update), proto)

      assert %UpdateInsuranceResponse{
               insurance: %Proto.PatientProfile.Insurance{
                 member_id: "member_id",
                 provider: %Proto.Insurance.Provider{
                   id: _,
                   logo_url: _,
                   name: "provider_name"
                 }
               }
             } = proto_response(conn, 200, UpdateInsuranceResponse)
    end
  end

  describe "DELETE delete" do
    setup [:proto_content, :authenticate_patient]

    test "succeedes", %{conn: conn, current_patient: current_patient} do
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: current_patient.id)
      country = Postgres.Factory.insert(:country, [])

      provider =
        Insurance.Factory.insert(:provider, %{
          name: "provider_name",
          country_id: country.id
        })

      {:ok, _} =
        Accounts.set(
          %{
            provider_id: provider.id,
            member_id: "member_id"
          },
          current_patient.id
        )

      conn = delete(conn, patient_insurance_path(conn, :delete))

      assert %DeleteInsuranceResponse{
               insurance: nil
             } = proto_response(conn, 200, DeleteInsuranceResponse)
    end
  end
end
