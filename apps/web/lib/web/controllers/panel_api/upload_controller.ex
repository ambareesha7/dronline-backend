defmodule Web.PanelApi.UploadController do
  use Web, :controller

  def profile_image_url(conn, params) do
    %{"file_name" => file_name, "content_type" => content_type} = params

    {:ok, upload_url, download_url} =
      Upload.generate_url_for_specialist_image(file_name, content_type)

    conn
    |> put_view(Proto.UploadView)
    |> render("upload.proto", %{upload_url: upload_url, download_url: download_url})
  end
end
