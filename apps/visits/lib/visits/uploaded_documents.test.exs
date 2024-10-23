defmodule Visits.UploadedDocumentsTest do
  use Postgres.DataCase, async: true

  alias Visits.UploadedDocuments

  setup do
    %{
      patient_id: 1,
      record_id: 1,
      document_url: "https://example.com"
    }
  end

  test """
         - allows to create one or multiple files
         - fetches documents by visit and specialist id
         - fetches documents by visit and patient id
       """,
       %{
         patient_id: patient_id,
         record_id: record_id
       } = params do
    {:ok, _uploaded_document} = UploadedDocuments.create(params)

    {:ok, [_fetched_uploaded_document]} = UploadedDocuments.by_record(params.record_id)

    second_entry_params = Map.put(params, :document_url, "https://second_entry_example.com")
    {:ok, _second_uploaded_document} = UploadedDocuments.create(second_entry_params)

    {:ok, fetched_uploaded_documents} =
      UploadedDocuments.by_record_and_patient(params.record_id, params.patient_id)

    assert [
             %{
               patient_id: ^patient_id,
               record_id: ^record_id,
               document_url: "https://example.com"
             },
             %{
               patient_id: ^patient_id,
               record_id: ^record_id,
               document_url: "https://second_entry_example.com"
             }
           ] = Enum.sort_by(fetched_uploaded_documents, & &1.document_url)
  end
end
