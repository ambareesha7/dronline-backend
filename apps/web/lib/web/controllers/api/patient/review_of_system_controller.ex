defmodule Web.Api.Patient.ReviewOfSystemController do
  use Web, :controller

  action_fallback Web.FallbackController

  @decode Proto.PatientProfile.UpdateReviewOfSystemRequest
  def update(conn, _params) do
    patient_id = conn.assigns.current_patient_id
    form_proto = conn.assigns.protobuf.review_of_system

    with {:ok, review_of_system} <-
           PatientProfile.register_review_of_system_change(patient_id, form_proto) do
      conn |> render("update.proto", %{review_of_system: review_of_system})
    end
  end

  def show(conn, _params) do
    patient_id = conn.assigns.current_patient_id

    review_of_system = PatientProfile.get_latest_review_of_system(patient_id)

    conn |> render("show.proto", %{review_of_system: review_of_system})
  end

  def history(conn, params) do
    patient_id = conn.assigns.current_patient_id

    {:ok, review_of_system_history, next_token} =
      PatientProfile.fetch_review_of_system_history(patient_id, params)

    specialist_ids = Enum.map(review_of_system_history, & &1.provided_by_specialist_id)
    specialists_generic_data = Web.SpecialistGenericData.get_by_ids(specialist_ids)

    patient_generic_data = Web.PatientGenericData.get_by_id(patient_id)

    conn
    |> render("history.proto", %{
      review_of_system_history: review_of_system_history,
      next_token: next_token,
      specialists_generic_data: specialists_generic_data,
      patient_generic_data: patient_generic_data
    })
  end
end

defmodule Web.Api.Patient.ReviewOfSystemView do
  use Web, :view

  def render("update.proto", %{review_of_system: review_of_system}) do
    %Proto.PatientProfile.UpdateReviewOfSystemResponse{
      review_of_system: Web.View.PatientProfile.render_review_of_system(review_of_system)
    }
  end

  def render("show.proto", %{review_of_system: review_of_system}) do
    %Proto.PatientProfile.GetReviewOfSystemResponse{
      review_of_system: Web.View.PatientProfile.render_review_of_system(review_of_system)
    }
  end

  def render("history.proto", %{
        review_of_system_history: review_of_system_history,
        next_token: next_token,
        specialists_generic_data: specialists_generic_data,
        patient_generic_data: patient_generic_data
      }) do
    %Proto.PatientProfile.GetReviewOfSystemHistoryResponse{
      review_of_system_history:
        Enum.map(review_of_system_history, &Web.View.PatientProfile.render_review_of_system/1),
      next_token: next_token,
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1),
      patient: Web.View.Generics.render_patient(patient_generic_data)
    }
  end
end
