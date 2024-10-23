defmodule Web.Api.AccountDeletionControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Authentication.SendPatientAccountDeletionRequest
  alias Proto.Errors.SimpleError

  describe "POST delete_account" do
    setup [:proto_content, :authenticate_patient]

    test "success", %{conn: conn} do
      proto =
        %{}
        |> SendPatientAccountDeletionRequest.new()
        |> SendPatientAccountDeletionRequest.encode()

      conn = post(conn, account_deletion_path(conn, :delete_account), proto)

      assert response(conn, 200)
    end

    test "return 422 with error message when already exists for the same patient", %{conn: conn} do
      proto =
        %{}
        |> SendPatientAccountDeletionRequest.new()
        |> SendPatientAccountDeletionRequest.encode()

      conn_1 = post(conn, account_deletion_path(conn, :delete_account), proto)
      assert response(conn_1, 200)

      conn_2 = post(conn, account_deletion_path(conn, :delete_account), proto)

      assert error_response = proto_response(conn_2, 422, SimpleError)

      assert String.contains?(
               error_response.message,
               "Your request is already being processed by the DrOnline Team."
             )
    end

    test "does not raise errors when data send to protobuf decoder is garbage", %{conn: conn} do
      proto = "e30="

      conn = post(conn, account_deletion_path(conn, :delete_account), proto)

      assert response(conn, 200)
    end
  end
end
