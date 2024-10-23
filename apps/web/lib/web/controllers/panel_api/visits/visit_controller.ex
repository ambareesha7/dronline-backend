defmodule Web.PanelApi.Visits.VisitController do
  use Conductor
  use Web, :controller

  action_fallback Web.FallbackController

  plug Web.Plugs.AssignQuerySpecialistId, [] when action in [:show]

  @authorize scopes: ["GP", "EXTERNAL"]
  def pending(conn, _params) do
    gp_id = conn.assigns.current_specialist_id
    pending_visits = Visits.fetch_pending_visits(gp_id)

    specialist_ids = Enum.map(pending_visits, & &1.specialist_id)
    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(specialist_ids)

    patient_ids = Enum.map(pending_visits, & &1.patient_id)
    patients_generic_data = Web.PatientGenericData.get_by_ids(patient_ids)

    conn
    |> render("pending.proto", %{
      visits: pending_visits,
      specialists_generic_data: specialists_generic_data,
      patients_generic_data: patients_generic_data
    })
  end

  @authorize scopes: ["EXTERNAL"]
  def pending_for_specialist(conn, params) do
    params =
      %{
        limit: params["limit"],
        visit_types:
          if(params["visit_types"],
            do: params |> Map.get("visit_types", []) |> Enum.map(&String.to_existing_atom/1)
          ),
        today: if(params["today"] == "true", do: true, else: false),
        exclude_today: if(params["exclude_today"] == "true", do: true, else: false)
      }

    specialist_id = conn.assigns.current_specialist_id
    pending_visits = Visits.fetch_pending_visits_for_specialist(specialist_id, params)

    patient_ids = Enum.map(pending_visits, & &1.patient_id)
    patients_generic_data = Web.PatientGenericData.get_by_ids(patient_ids)

    conn
    |> render("upcoming.proto", %{
      visits: pending_visits,
      patients_generic_data: patients_generic_data
    })
  end

  @authorize scopes: ["EXTERNAL"]
  def ended(conn, params) do
    specialist_id = conn.assigns.current_specialist_id

    {:ok, ended_visits, next_token} =
      Visits.fetch_ended_visits_for_specialist(specialist_id, params)

    patient_ids = Enum.map(ended_visits, & &1.patient_id)
    patients_generic_data = Web.PatientGenericData.get_by_ids(patient_ids)

    conn
    |> render("ended.proto", %{
      visits: ended_visits,
      patients_generic_data: patients_generic_data,
      next_token: next_token
    })
  end

  @authorize scopes: ["EXTERNAL"]
  def move_to_canceled(conn, params) do
    visit_id = params["visit_id"]

    with {:ok, _canceled_visit} <-
           Visits.move_visit_from_pending_to_canceled(visit_id, %{"canceled_by" => "doctor"}) do
      conn |> send_resp(200, "")
    end
  end

  @authorize scopes: ["GP", "EXTERNAL"]
  def show(conn, %{"visit_id" => visit_id}) do
    {:ok, visit} = Visits.fetch(visit_id)
    {:ok, category} = Visits.fetch_medical_category(visit.chosen_medical_category_id)

    conn
    |> render(
      "show.proto",
      %{
        visit: visit,
        medical_category: category
      }
    )
  end

  @authorize scopes: ["GP", "EXTERNAL"]
  def uploaded_documents(conn, %{"record_id" => record_id}) do
    {:ok, uploaded_documents} = Visits.UploadedDocuments.by_record(record_id)

    render(conn, "uploaded_documents.proto", %{uploaded_documents: uploaded_documents})
  end

  @authorize scopes: ["GP", "EXTERNAL"]
  def payment_for_visit(conn, %{"record_id" => record_id}) do
    record_id = String.to_integer(record_id)

    with {:ok, payment} <-
           Visits.fetch_payment_by_record_id(record_id) do
      conn
      |> put_view(Web.Common.Visits.VisitView)
      |> render("payment.proto", %{payment: payment, record_id: record_id})
    end
  end
end

defmodule Web.PanelApi.Visits.VisitView do
  use Web, :view

  def render("pending.proto", %{
        visits: visits,
        specialists_generic_data: specialists_generic_data,
        patients_generic_data: patients_generic_data
      }) do
    %Proto.Visits.GetPendingVisitsResponse{
      visits: Enum.map(visits, &Web.View.Visits.render_visit_data_for_specialist/1),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1),
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1)
    }
  end

  def render("upcoming.proto", %{
        visits: visits,
        patients_generic_data: patients_generic_data
      }) do
    %Proto.Visits.GetDoctorPendingVisitsResponse{
      visits: Enum.map(visits, &Web.View.Visits.render_visit_data_for_specialist/1),
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1)
    }
  end

  def render("ended.proto", %{
        visits: visits,
        patients_generic_data: patients_generic_data,
        next_token: next_token
      }) do
    %Proto.Visits.GetEndedVisitsResponse{
      visits: Enum.map(visits, &Web.View.Visits.render_visit_data_for_specialist/1),
      patients: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1),
      next_token: next_token
    }
  end

  def render("show.proto", %{
        visit: visit,
        medical_category: medical_category
      }) do
    %Proto.Visits.GetVisitResponse{
      visit: Web.View.Visits.render_visit_data_for_specialist(visit),
      medical_category: Web.View.Visits.render_medical_category(medical_category)
    }
  end

  def render("uploaded_documents.proto", %{
        uploaded_documents: uploaded_documents
      }) do
    %Proto.Visits.GetUploadedDocuments{
      document_urls: Enum.map(uploaded_documents, &Upload.signed_download_url(&1.document_url))
    }
  end
end
