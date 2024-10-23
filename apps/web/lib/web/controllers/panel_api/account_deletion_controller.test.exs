defmodule Web.PanelApi.AccountDeletionControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Errors.SimpleError
  alias Proto.PanelAuthentication.SendSpecialistAccountDeletionRequest

  describe "POST delete_account" do
    setup [:proto_content, :authenticate_gp]

    test "success", %{conn: conn} do
      proto =
        %{}
        |> SendSpecialistAccountDeletionRequest.new()
        |> SendSpecialistAccountDeletionRequest.encode()

      conn = post(conn, panel_account_deletion_path(conn, :delete_account), proto)

      assert response(conn, 200)
    end

    test "return 422 with error message when already exists for the same specialist", %{
      conn: conn
    } do
      proto =
        %{}
        |> SendSpecialistAccountDeletionRequest.new()
        |> SendSpecialistAccountDeletionRequest.encode()

      conn_1 = post(conn, panel_account_deletion_path(conn, :delete_account), proto)
      assert response(conn_1, 200)

      conn_2 = post(conn, panel_account_deletion_path(conn, :delete_account), proto)

      assert error_response = proto_response(conn_2, 422, SimpleError)

      assert String.contains?(
               error_response.message,
               "Your request is already being processed by the DrOnline Team."
             )
    end
  end
end
