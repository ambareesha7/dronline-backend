defmodule Web.LandingApi.UrgentHelpRequestControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Visits.LandingUrgentHelpRequest
  alias Proto.Visits.LandingUrgentHelpResponse

  setup [:proto_content]

  describe "POST request_urgent_help" do
    test "successfully creates an urgent help request", %{conn: conn} do
      proto =
        %LandingUrgentHelpRequest{
          phone_number: "+48123456789",
          email: "test@example.com",
          first_name: "John",
          last_name: "Doe"
        }
        |> LandingUrgentHelpRequest.encode()

      conn =
        conn
        |> post(landing_urgent_help_request_path(conn, :request_urgent_help), proto)

      response =
        proto_response(conn, 200, LandingUrgentHelpResponse)

      assert %LandingUrgentHelpResponse{
               patient_id: patient_id,
               urgent_help_request_id: urgent_help_request_id,
               payment_url: payment_url,
               auth_token: auth_token
             } = response

      assert patient_id
      assert urgent_help_request_id
      assert payment_url
      assert auth_token
    end

    test "handles failure in creating a patient account", %{conn: conn} do
      proto =
        %LandingUrgentHelpRequest{
          phone_number: "invalid",
          email: "invalid",
          first_name: "John",
          last_name: "Doe"
        }
        |> LandingUrgentHelpRequest.encode()

      conn =
        conn
        |> post(landing_urgent_help_request_path(conn, :request_urgent_help), proto)

      assert response(conn, 422)
    end
  end
end
