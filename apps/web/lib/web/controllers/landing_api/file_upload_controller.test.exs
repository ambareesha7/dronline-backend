defmodule Web.LandingApi.FileUploadControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Uploads.UploadResponse

  @date_today Date.utc_today() |> Date.to_string()

  describe "GET second_opinion_file_url" do
    test "returns upload url and resource path", %{conn: conn} do
      params = [file_name: "test.png", content_type: "image/png"]

      conn =
        get(conn, landing_file_upload_path(conn, :second_opinion_file_url, params))

      assert %UploadResponse{
               upload_url: upload_url,
               download_url: download_url
             } = proto_response(conn, 200, UploadResponse)

      assert upload_url =~ "https://"
      refute download_url =~ "https://"

      assert download_url =~ "/landing_second_opinion/#{@date_today}"
      assert download_url =~ "/test.png"
    end
  end

  test "removes spaces from file name while uploading", %{conn: conn} do
    file_name = "example (1).pdf"

    params = [file_name: file_name, content_type: "image/png"]

    conn =
      conn
      |> get(landing_file_upload_path(conn, :second_opinion_file_url, params))

    assert %UploadResponse{
             upload_url: upload_url,
             download_url: download_url
           } = proto_response(conn, 200, UploadResponse)

    assert upload_url =~ "https://"
    refute download_url =~ "https://"

    assert download_url =~ "/dronline-dev/landing_second_opinion/#{@date_today}"
    assert download_url =~ String.replace(file_name, " ", "")
  end

  test "encodes file name for visit", %{conn: conn} do
    file_name = "żółty.pdf"
    params = [file_name: file_name, content_type: "image/png"]

    conn =
      conn
      |> get(landing_file_upload_path(conn, :second_opinion_file_url, params))

    assert %UploadResponse{
             upload_url: upload_url,
             download_url: download_url
           } = proto_response(conn, 200, UploadResponse)

    assert upload_url =~ "https://"
    refute download_url =~ "https://"

    assert download_url =~ "/dronline-dev/landing_second_opinion/#{@date_today}"
    assert download_url =~ URI.encode(file_name)
  end
end
