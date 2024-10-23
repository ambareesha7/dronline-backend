defmodule Proto.UploadView do
  use Proto.View

  def render("upload.proto", %{upload_url: upload_url, download_url: download_url}) do
    %{
      upload_url: upload_url,
      download_url: download_url
    }
    |> Proto.validate!(Proto.Uploads.UploadResponse)
    |> Proto.Uploads.UploadResponse.new()
  end
end
