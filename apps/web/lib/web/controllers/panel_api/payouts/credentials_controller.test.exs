defmodule Web.PanelApi.Payouts.CredentialsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Payouts.GetCredentialsResponse
  alias Proto.Payouts.UpdateCredentialsRequest

  describe "GET show" do
    setup [:proto_content, :authenticate_external]

    test "returns empty credentials", %{conn: conn} do
      conn = get(conn, panel_payouts_credentials_path(conn, :show))

      assert %GetCredentialsResponse{credentials: nil} =
               proto_response(conn, 200, GetCredentialsResponse)
    end

    test "returns existing credentials", %{conn: conn, current_external: current_external} do
      Payouts.Factory.insert(:credentials, specialist_id: current_external.id, iban: "0000")

      conn = get(conn, panel_payouts_credentials_path(conn, :show))

      assert %GetCredentialsResponse{
               credentials: %Proto.Payouts.Credentials{
                 iban: "0000"
               }
             } = proto_response(conn, 200, GetCredentialsResponse)
    end
  end

  @correct_params %Proto.Payouts.Credentials{
    iban: "0000",
    name: "name",
    bank_name: "bank_name",
    bank_swift_code: "bank_swift_code"
  }

  describe "UPDATE update" do
    setup [:proto_content, :authenticate_external]

    test "creates new credentials", %{conn: conn} do
      proto =
        %UpdateCredentialsRequest{credentials: @correct_params}
        |> UpdateCredentialsRequest.encode()

      conn = put(conn, panel_payouts_credentials_path(conn, :update), proto)

      assert %GetCredentialsResponse{
               credentials: %Proto.Payouts.Credentials{
                 iban: "0000"
               }
             } = proto_response(conn, 200, GetCredentialsResponse)
    end

    test "updates existing credentials", %{conn: conn, current_external: current_external} do
      Payouts.Factory.insert(:credentials, specialist_id: current_external.id, iban: "1111")

      proto =
        %UpdateCredentialsRequest{credentials: @correct_params}
        |> UpdateCredentialsRequest.encode()

      conn = put(conn, panel_payouts_credentials_path(conn, :update), proto)

      assert %GetCredentialsResponse{
               credentials: %Proto.Payouts.Credentials{
                 iban: "0000"
               }
             } = proto_response(conn, 200, GetCredentialsResponse)
    end

    test "returns validation error", %{conn: conn} do
      proto =
        %UpdateCredentialsRequest{
          credentials: %Proto.Payouts.Credentials{name: "rest of fields missing"}
        }
        |> UpdateCredentialsRequest.encode()

      conn = put(conn, panel_payouts_credentials_path(conn, :update), proto)

      assert proto_response(conn, 422, GetCredentialsResponse)
    end
  end
end
