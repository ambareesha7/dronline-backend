defmodule Web.Api.ResizeControllerTest do
  use Web.ConnCase, async: true

  describe "GET resize" do
    setup [:authenticate_patient]

    test "success with all params", %{conn: conn} do
      conn = get(conn, resize_path(conn, :resize, width: "200", height: "200", url: "URL"))

      assert response(conn, 200)
    end
  end
end
