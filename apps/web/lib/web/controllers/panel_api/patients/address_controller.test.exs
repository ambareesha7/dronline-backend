defmodule Web.PanelApi.Patients.AddressControllerTest do
  use Web.ConnCase, async: true

  alias Proto.PatientProfile.GetAddressResponse
  alias Proto.PatientProfile.UpdateAddressRequest
  alias Proto.PatientProfile.UpdateAddressResponse

  alias Proto.PatientProfile.Address

  alias Proto.Errors.ErrorResponse
  alias Proto.Errors.FormErrors

  describe "GET show" do
    setup [:authenticate_gp]

    test "returns empty address when it doesn't exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      conn = get(conn, panel_patients_address_path(conn, :show, patient))

      assert %GetAddressResponse{address: %Address{city: ""}} =
               proto_response(conn, 200, GetAddressResponse)
    end

    test "returns address when it exists", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id, city: "New York")

      conn = get(conn, panel_patients_address_path(conn, :show, patient))

      assert %GetAddressResponse{address: %Address{city: "New York"}} =
               proto_response(conn, 200, GetAddressResponse)
    end

    test "returns not_found error when patient doesn't exist", %{conn: conn} do
      conn = get(conn, panel_patients_address_path(conn, :show, 0))

      assert response(conn, 404)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_gp]

    test "returns newly created address", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

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

      conn = put(conn, panel_patients_address_path(conn, :update, patient), proto)

      assert %UpdateAddressResponse{address: %Address{city: "Poznań"}} =
               proto_response(conn, 200, UpdateAddressResponse)
    end

    test "returns updated address", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id, city: "New York")

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

      conn = put(conn, panel_patients_address_path(conn, :update, patient), proto)

      assert %UpdateAddressResponse{address: %Address{city: "Poznań"}} =
               proto_response(conn, 200, UpdateAddressResponse)
    end

    test "returns not_found error when patient doesn't exist", %{conn: conn} do
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

      conn = put(conn, panel_patients_address_path(conn, :update, 0), proto)
      assert response(conn, 404)
    end

    test "returns error on validation failure", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      proto =
        %{
          address: Address.new()
        }
        |> UpdateAddressRequest.new()
        |> UpdateAddressRequest.encode()

      conn = put(conn, panel_patients_address_path(conn, :update, patient), proto)

      %ErrorResponse{form_errors: %FormErrors{}} = proto_response(conn, 422, ErrorResponse)
    end
  end
end
