defmodule Web.PingControllerTest do
  use Web.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, "/ping")

    assert response(conn, 200) == "pong"
  end
end
