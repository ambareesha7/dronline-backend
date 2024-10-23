defmodule Web.PanelApi.Calls.PatientLocationCoordinatesControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Calls.GetPatientLocationCoordinatesResponse

  describe "GET show" do
    setup [:authenticate_gp, :accept_proto]

    test "returns coordinates if they were stored in call", %{conn: conn} do
      call_id = Calls.Call.start()
      Calls.Call.store_patient_location_coordinates(call_id, %{lat: 15.1, lon: 67.93})

      conn = get(conn, panel_calls_patient_location_coordinates_path(conn, :show, call_id))

      %GetPatientLocationCoordinatesResponse{
        patient_location_coordinates: %Proto.Generics.Coordinates{
          lat: fetched_lat,
          lon: fetched_lon
        }
      } = proto_response(conn, 200, GetPatientLocationCoordinatesResponse)

      assert Float.round(fetched_lat, 1) == 15.1
      assert Float.round(fetched_lon, 2) == 67.93
    end

    test "returns empty response if coordinates weren't stored in call", %{conn: conn} do
      call_id = Calls.Call.start()

      conn = get(conn, panel_calls_patient_location_coordinates_path(conn, :show, call_id))

      %GetPatientLocationCoordinatesResponse{
        patient_location_coordinates: nil
      } = proto_response(conn, 200, GetPatientLocationCoordinatesResponse)
    end

    test "returns empty response if call is not ongoing", %{conn: conn} do
      call_id = UUID.uuid4()

      conn = get(conn, panel_calls_patient_location_coordinates_path(conn, :show, call_id))

      %GetPatientLocationCoordinatesResponse{
        patient_location_coordinates: nil
      } = proto_response(conn, 200, GetPatientLocationCoordinatesResponse)
    end
  end
end
