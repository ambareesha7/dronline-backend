defmodule Web.LandingApi.FileUploadController do
  use Web, :controller

  require Logger

  action_fallback Web.FallbackController

  def second_opinion_file_url(conn, params) do
    %{"file_name" => file_name, "content_type" => content_type} = params

    file_name = String.replace(file_name, " ", "")
    date_now = DateTime.utc_now() |> DateTime.to_string() |> String.replace(" ", "")
    file_path = URI.encode("/landing_second_opinion/#{date_now}/#{UUID.uuid4()}/#{file_name}")

    {:ok, upload_url, resource_path} =
      Upload.generate_us_board_landing_upload_url(file_path, content_type)

    _ = Logger.info(fn -> "GCS UPLOAD URL: " <> upload_url end)

    conn
    |> put_view(Proto.UploadView)
    |> render("upload.proto", %{upload_url: upload_url, download_url: resource_path})
  end
end
