defmodule Web.Api.Patients.InsuranceControllerTest do
  use Web.ConnCase, async: true

  alias Insurance.Accounts
  alias Proto.PatientProfile.GetInsuranceResponse
  alias Proto.PatientProfile.UpdateInsuranceRequest
  alias Proto.PatientProfile.UpdateInsuranceResponse

  describe "GET show" do
    setup [:authenticate_gp]

    test "success when insurance doesn't exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      conn = get(conn, panel_patients_insurance_path(conn, :show, patient))

      assert %GetInsuranceResponse{
               insurance: nil
             } = proto_response(conn, 200, GetInsuranceResponse)
    end

    test "success when insurance exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
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
          patient.id
        )

      conn = get(conn, panel_patients_insurance_path(conn, :show, patient))

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
    setup [:proto_content, :authenticate_gp]

    test "succeedes", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
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

      conn = put(conn, panel_patients_insurance_path(conn, :update, patient), proto)

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
end
