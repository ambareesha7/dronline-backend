defmodule Web.Api.FileUploadController do
  use Web, :controller

  require Logger

  action_fallback Web.FallbackController

  def generate_signed_url(conn, params) do
    %{"file_name" => file_name, "content_type" => content_type} = params
    patient_id = conn.assigns.current_patient_id

    file_path = "/patient_file_uploads/#{patient_id}/#{UUID.uuid4()}/#{file_name}"

    {:ok, upload_url, resource_path} = Upload.generate_private_upload_url(file_path, content_type)

    _ = Logger.info(fn -> "GCS UPLOAD URL: " <> upload_url end)

    conn
    |> render("generate_signed_url.proto", %{
      upload_url: upload_url,
      resource_path: resource_path
    })
  end

  @decode Proto.Uploads.PostDocumentToVisitRequest
  def upload_document_for_visit(conn, _params) do
    %{
      file_name: file_name,
      record_id: record_id,
      content_type: content_type
    } = conn.assigns.protobuf

    file_name = String.replace(file_name, " ", "")

    patient_id = conn.assigns.current_patient_id
    file_path = URI.encode("/visit/#{patient_id}/#{UUID.uuid4()}/#{file_name}")

    {:ok, upload_url, resource_path} = Upload.generate_private_upload_url(file_path, content_type)

    _ = Logger.info(fn -> "GCS UPLOAD URL: " <> upload_url end)

    with {:ok, _uploaded_document} <-
           Visits.UploadedDocuments.create(%{
             document_url: resource_path,
             record_id: record_id,
             patient_id: patient_id
           }) do
      conn
      |> render("generate_signed_url.proto", %{
        upload_url: upload_url,
        resource_path: resource_path
      })
    end
  end
end

defmodule Web.Api.FileUploadView do
  use Web, :view

  def render("generate_signed_url.proto", %{
        upload_url: upload_url,
        resource_path: resource_path
      }) do
    %Proto.Uploads.GetFileUploadUrlResponse{
      upload_url: upload_url,
      resource_path: resource_path
    }
  end
end
