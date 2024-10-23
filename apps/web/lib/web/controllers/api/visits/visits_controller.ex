defmodule Web.Api.Visits.VisitsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def my_visits(conn, params) do
    current_patient_id = conn.assigns.current_patient_id

    with {:ok, patients_ids} <- resolve_patients_ids(current_patient_id, params) do
      {:ok, visits, next_token} = Visits.fetch_visits_for_patients(patients_ids, params)
      patients_generic_data = Web.PatientGenericData.get_by_ids(patients_ids)

      conn
      |> render("my_visits.proto", %{
        visits: visits,
        next_token: next_token |> Web.ControllerHelper.next_token_to_string(),
        patients_generic_data: patients_generic_data
      })
    end
  end

  def show(conn, params) do
    visit_id = params["visit_id"]

    with {:ok, visit_data} <- Visits.fetch_for_patient(visit_id) do
      render(conn, "show.proto", %{visit_data: visit_data})
    end
  end

  def move_to_canceled(conn, params) do
    visit_id = params["visit_id"]

    with {:ok, canceled_visit} <-
           Visits.move_visit_from_pending_to_canceled(visit_id, %{"canceled_by" => "patient"}) do
      {_result, refund} = Visits.Payments.fetch_refund_record_id(canceled_visit.record_id)

      render(conn, "visit_canceled.proto", %{refund: refund})
    end
  end

  def uploaded_documents(conn, %{"record_id" => record_id}) do
    record_id = String.to_integer(record_id)
    current_patient_id = conn.assigns.current_patient_id

    {:ok, uploaded_documents} =
      Visits.UploadedDocuments.by_record_and_patient(record_id, current_patient_id)

    render(conn, "uploaded_documents.proto", %{uploaded_documents: uploaded_documents})
  end

  def payment_for_visit(conn, %{"record_id" => record_id}) do
    record_id = String.to_integer(record_id)
    current_patient_id = conn.assigns.current_patient_id

    with {:ok, payment} <-
           Visits.fetch_payment_by_record_and_patient_id(record_id, current_patient_id) do
      conn
      |> put_view(Web.Common.Visits.VisitView)
      |> render("payment.proto", %{payment: payment, record_id: record_id})
    end
  end

  defp resolve_patients_ids(current_patient_id, params) do
    case params["patient"] do
      id when id in [nil, ""] ->
        related_patients_ids =
          PatientProfilesManagement.get_related_child_patient_ids(current_patient_id)

        {:ok, [current_patient_id] ++ related_patients_ids}

      "0" ->
        {:ok, [current_patient_id]}

      id ->
        parsed_id = String.to_integer(id)

        related_patients_ids =
          PatientProfilesManagement.get_related_child_patient_ids(current_patient_id)

        if parsed_id in related_patients_ids do
          {:ok, [parsed_id]}
        else
          {:error, :forbidden}
        end
    end
  end
end

defmodule Web.Api.Visits.VisitsView do
  use Web, :view

  def render("my_visits.proto", %{
        visits: visits,
        next_token: next_token,
        patients_generic_data: patients_generic_data
      }) do
    %Proto.Visits.GetVisitsResponse{
      visits: Enum.map(visits, &Web.View.Visits.render_visit_data_for_patient/1),
      next_token: next_token,
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1)
    }
  end

  def render("show.proto", %{
        visit_data: visit_data
      }) do
    %Proto.Visits.GetPatientVisitResponse{
      visit: Web.View.Visits.render_visit_data_for_patient(visit_data)
    }
  end

  def render("uploaded_documents.proto", %{
        uploaded_documents: uploaded_documents
      }) do
    %Proto.Visits.GetUploadedDocuments{
      document_urls: Enum.map(uploaded_documents, &Upload.signed_download_url(&1.document_url))
    }
  end

  def render("visit_canceled.proto", %{refund: refund}) do
    %Proto.Visits.MoveVisitToCanceledResponse{
      refund: parse_refund(refund)
    }
  end

  defp parse_refund(%Visits.Visit.Payment.Refund{
         payment: %Visits.Visit.Payment{payment_method: :telr}
       }),
       do: true

  defp parse_refund(_refund), do: false
end
