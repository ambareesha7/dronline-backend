defmodule Web.Api.FileUploadControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Uploads.GetFileUploadUrlResponse
  alias Proto.Uploads.PostDocumentToVisitRequest

  setup [:authenticate_patient, :proto_content]

  describe "GET generate_signed_url" do
    test "returns upload url and resource path", %{conn: conn, current_patient: patient} do
      params = %{"file_name" => "avatar.jpg", "content_type" => "image/jpeg"}
      conn = get(conn, file_upload_path(conn, :generate_signed_url), params)

      assert %GetFileUploadUrlResponse{
               upload_url: upload_url,
               resource_path: resource_path
             } = proto_response(conn, 200, GetFileUploadUrlResponse)

      assert upload_url =~ "https://"
      refute resource_path =~ "https://"

      assert resource_path =~ "/patient_file_uploads/#{patient.id}"
      assert resource_path =~ "/avatar.jpg"
    end
  end

  test "creates file for a visit", %{conn: conn, current_patient: patient} do
    record_id = 1
    patient_id = patient.id

    proto =
      %{
        record_id: record_id,
        file_name: "example.pdf",
        content_type: "application/pdf"
      }
      |> PostDocumentToVisitRequest.new()
      |> PostDocumentToVisitRequest.encode()

    conn =
      conn
      |> post(file_upload_path(conn, :upload_document_for_visit), proto)

    assert %GetFileUploadUrlResponse{
             upload_url: upload_url,
             resource_path: resource_path
           } = proto_response(conn, 200, GetFileUploadUrlResponse)

    assert upload_url =~ "https://"
    refute resource_path =~ "https://"

    assert resource_path =~ "/dronline-dev/visit/#{patient.id}/"
    assert resource_path =~ "/example.pdf"

    assert {:ok,
            [
              %{
                document_url: ^resource_path,
                record_id: ^record_id,
                patient_id: ^patient_id
              }
            ]} = Visits.UploadedDocuments.by_record(record_id)
  end

  test "removes spaces from file name while uploading", %{conn: conn, current_patient: patient} do
    record_id = 1
    file_name = "example (1).pdf"

    proto =
      %{
        record_id: record_id,
        file_name: file_name,
        content_type: "application/pdf"
      }
      |> PostDocumentToVisitRequest.new()
      |> PostDocumentToVisitRequest.encode()

    conn =
      conn
      |> post(file_upload_path(conn, :upload_document_for_visit), proto)

    assert %GetFileUploadUrlResponse{
             upload_url: upload_url,
             resource_path: resource_path
           } = proto_response(conn, 200, GetFileUploadUrlResponse)

    assert upload_url =~ "https://"
    refute resource_path =~ "https://"

    assert resource_path =~ "/dronline-dev/visit/#{patient.id}/"
    assert resource_path =~ String.replace(file_name, " ", "")
  end

  test "encodes file name for visit", %{conn: conn, current_patient: patient} do
    record_id = 1
    file_name = "żółty.pdf"

    proto =
      %{
        record_id: record_id,
        file_name: file_name,
        content_type: "application/pdf"
      }
      |> PostDocumentToVisitRequest.new()
      |> PostDocumentToVisitRequest.encode()

    conn =
      conn
      |> post(file_upload_path(conn, :upload_document_for_visit), proto)

    assert %GetFileUploadUrlResponse{
             upload_url: upload_url,
             resource_path: resource_path
           } = proto_response(conn, 200, GetFileUploadUrlResponse)

    assert upload_url =~ "https://"
    refute resource_path =~ "https://"

    assert resource_path =~ "/dronline-dev/visit/#{patient.id}/"
    assert resource_path =~ URI.encode(file_name)
  end
end
