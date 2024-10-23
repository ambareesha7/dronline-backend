defmodule Web.PanelApi.UploadControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Uploads.UploadResponse

  describe "GET profile_image_url" do
    setup [:authenticate_gp]

    test "success", %{conn: conn} do
      params = [file_name: "test.png", content_type: "image/png"]

      path = panel_upload_path(conn, :profile_image_url, params)

      conn = get(conn, path)

      assert %UploadResponse{} = proto_response(conn, 200, UploadResponse)
    end
  end
end
