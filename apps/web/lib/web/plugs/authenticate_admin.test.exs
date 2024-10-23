defmodule Web.Plugs.AuthenticateAdminTest do
  use Web.ConnCase, async: true

  alias Web.Plugs.AuthenticateAdmin

  test "assigns data if token is valid", %{
    conn: conn
  } do
    admin = Authentication.Factory.insert(:admin)

    conn =
      conn
      |> put_req_header("x-auth-token", admin.auth_token)
      |> AuthenticateAdmin.call(%{})

    assert conn.assigns.current_admin_id == admin.id
    assert conn.assigns.scopes == ["ADMIN"]
    refute conn.halted
  end

  test "returns 401 if token is missing", %{conn: conn} do
    conn = AuthenticateAdmin.call(conn, %{})

    assert response(conn, 401)
    assert conn.halted
  end
end
