defmodule Web.Api.Patient.AddressControllerTest do
  use Web.ConnCase, async: true

  alias Proto.PatientProfile.GetAddressResponse
  alias Proto.PatientProfile.UpdateAddressRequest
  alias Proto.PatientProfile.UpdateAddressResponse

  alias Proto.PatientProfile.Address

  alias Proto.Errors.ErrorResponse
  alias Proto.Errors.FormErrors

  describe "GET show (for adult patient)" do
    setup [:authenticate_patient]

    test "returns empty address when one was not provided yet", %{conn: conn} do
      conn = get(conn, patient_address_path(conn, :show))

      assert %GetAddressResponse{address: %Address{city: "", neighborhood: ""}} =
               proto_response(conn, 200, GetAddressResponse)
    end

    test "returns previously provided address", %{conn: conn, current_patient: current_patient} do
      _address =
        PatientProfile.Factory.insert(:address,
          patient_id: current_patient.id,
          city: "New York",
          neighborhood: "Bronks"
        )

      conn = get(conn, patient_address_path(conn, :show))

      assert %GetAddressResponse{address: %Address{city: "New York", neighborhood: "Bronks"}} =
               proto_response(conn, 200, GetAddressResponse)
    end
  end

  describe "GET show (for child patient)" do
    setup [:authenticate_patient]

    test "returns associated adult patient address when one wasn't provided for child yet",
         %{conn: conn, current_patient: current_patient} do
      adult_patient = PatientProfile.Factory.insert(:patient)

      _adult_patient_address =
        PatientProfile.Factory.insert(:address,
          patient_id: adult_patient.id,
          city: "New York",
          neighborhood: "Bronks"
        )

      cmd = %PatientProfilesManagement.Commands.RegisterFamilyRelationship{
        adult_patient_id: adult_patient.id,
        child_patient_id: current_patient.id
      }

      _ = PatientProfilesManagement.FamilyRelationship.register_family_relationship(cmd)

      conn = get(conn, patient_address_path(conn, :show))

      assert %GetAddressResponse{address: %Address{city: "New York", neighborhood: "Bronks"}} =
               proto_response(conn, 200, GetAddressResponse)
    end

    test "returns previously provided child address",
         %{conn: conn, current_patient: current_patient} do
      adult_patient = PatientProfile.Factory.insert(:patient)

      _adult_patient_address =
        PatientProfile.Factory.insert(:address,
          patient_id: adult_patient.id,
          city: "New York",
          neighborhood: "Bronks"
        )

      cmd = %PatientProfilesManagement.Commands.RegisterFamilyRelationship{
        adult_patient_id: adult_patient.id,
        child_patient_id: current_patient.id
      }

      _adult_patient_address =
        PatientProfile.Factory.insert(:address,
          patient_id: current_patient.id,
          city: "Poznań",
          neighborhood: "Piątkowo"
        )

      _ = PatientProfilesManagement.FamilyRelationship.register_family_relationship(cmd)

      conn = get(conn, patient_address_path(conn, :show))

      assert %GetAddressResponse{address: %Address{city: "Poznań", neighborhood: "Piątkowo"}} =
               proto_response(conn, 200, GetAddressResponse)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_patient]

    test "success when address doesn't exist", %{conn: conn} do
      proto =
        %{
          address:
            Address.new(
              street: "street",
              home_number: "home number",
              zip_code: "zip code",
              city: "Poznań",
              country: "country",
              neighborhood: "neighborhood"
            )
        }
        |> UpdateAddressRequest.new()
        |> UpdateAddressRequest.encode()

      conn = put(conn, patient_address_path(conn, :update), proto)

      assert %UpdateAddressResponse{
               address: %Address{city: "Poznań", neighborhood: "neighborhood"}
             } = proto_response(conn, 200, UpdateAddressResponse)
    end

    test "success when address exist", %{conn: conn, current_patient: current_patient} do
      _address =
        PatientProfile.Factory.insert(:address, patient_id: current_patient.id, city: "New York")

      proto =
        %{
          address:
            Address.new(
              street: "street",
              home_number: "home number",
              zip_code: "zip code",
              city: "Poznań",
              country: "country",
              neighborhood: "neighborhood"
            )
        }
        |> UpdateAddressRequest.new()
        |> UpdateAddressRequest.encode()

      conn = put(conn, patient_address_path(conn, :update), proto)

      assert %UpdateAddressResponse{
               address: %Address{city: "Poznań", neighborhood: "neighborhood"}
             } = proto_response(conn, 200, UpdateAddressResponse)
    end

    test "validation failure", %{conn: conn} do
      proto =
        %{
          address: Address.new()
        }
        |> UpdateAddressRequest.new()
        |> UpdateAddressRequest.encode()

      conn = put(conn, patient_address_path(conn, :update), proto)

      %ErrorResponse{form_errors: %FormErrors{}} = proto_response(conn, 422, ErrorResponse)
    end
  end
end
