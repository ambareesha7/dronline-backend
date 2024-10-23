defmodule Web.AdminApi.AuthControllerTest do
  use Web.ConnCase, async: true

  alias Proto.AdminAuthentication.LoginRequest
  alias Proto.AdminAuthentication.LoginResponse

  describe "POST login" do
    setup [:proto_content]

    test "verified specialist", %{conn: conn} do
      admin = Authentication.Factory.insert(:admin, password: "Password1!")

      proto =
        %{
          email: admin.email,
          password: "Password1!"
        }
        |> LoginRequest.new()
        |> LoginRequest.encode()

      conn = post(conn, admin_auth_path(conn, :login), proto)

      %LoginResponse{auth_token: auth_token} = proto_response(conn, 200, LoginResponse)

      assert auth_token == admin.auth_token
    end

    test "invalid credentials", %{conn: conn} do
      proto =
        %{
          email: "invalid",
          password: "invalid"
        }
        |> LoginRequest.new()
        |> LoginRequest.encode()

      conn = post(conn, admin_auth_path(conn, :login), proto)

      assert response(conn, 401)
    end
  end
end
