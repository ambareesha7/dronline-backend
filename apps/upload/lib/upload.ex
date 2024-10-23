defmodule Upload do
  @spec generate_url_for_specialist_image(String.t(), String.t()) :: {:ok, String.t(), String.t()}
  def generate_url_for_specialist_image(file_name, content_type) do
    ext = file_name |> Path.extname()
    file_path = "images/specialists/" <> UUID.uuid4() <> ext

    signer_params = %Upload.Signer.Params{
      verb: "PUT",
      md5_digest: "",
      content_type: content_type,
      extension: "x-goog-acl:public-read",
      expires: DateTime.utc_now() |> Timex.shift(hours: 1) |> Timex.to_unix(),
      resource: Path.join("/#{Application.get_env(:upload, :bucket)}", file_path)
    }

    upload_url = Upload.Signer.sign_url(signer_params)
    download_url = upload_url |> URI.parse() |> Map.put(:query, nil) |> URI.to_string()

    {:ok, upload_url, download_url}
  end

  @spec generate_private_upload_url(String.t(), String.t()) ::
          {:ok, upload_url :: String.t(), resource_path :: String.t()}
  def generate_private_upload_url(file_path, content_type) do
    signer_params = %Upload.Signer.Params{
      verb: "PUT",
      md5_digest: "",
      content_type: content_type,
      extension: "x-goog-acl:private",
      expires: DateTime.utc_now() |> Timex.shift(hours: 1) |> Timex.to_unix(),
      resource: Path.join("/#{Application.get_env(:upload, :bucket)}", file_path)
    }

    upload_url = Upload.Signer.sign_url(signer_params)

    {:ok, upload_url, signer_params.resource}
  end

  @spec generate_us_board_landing_upload_url(String.t(), String.t()) ::
          {:ok, upload_url :: String.t(), resource_path :: String.t()}
  def generate_us_board_landing_upload_url(file_path, content_type) do
    signer_params = %Upload.Signer.Params{
      verb: "PUT",
      md5_digest: "",
      content_type: content_type,
      extension: "x-goog-acl:public-read",
      expires: DateTime.utc_now() |> Timex.shift(hours: 1) |> Timex.to_unix(),
      resource: Path.join("/#{Application.get_env(:upload, :bucket)}", file_path)
    }

    upload_url = Upload.Signer.sign_url(signer_params)

    {:ok, upload_url, signer_params.resource}
  end

  @spec signed_download_url(String.t()) :: String.t()
  def signed_download_url(gcs_path) when is_binary(gcs_path) do
    signer_params = %Upload.Signer.Params{
      verb: "GET",
      md5_digest: "",
      content_type: "",
      extension: nil,
      expires: DateTime.utc_now() |> Timex.shift(hours: 1) |> Timex.to_unix(),
      resource: gcs_path
    }

    Upload.Signer.sign_url(signer_params)
  end
end
