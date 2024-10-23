defmodule Web.PanelApi.Calls.VisitCallController do
  use Conductor
  use Web, :controller

  alias Visits.PendingVisit

  action_fallback(Web.FallbackController)

  @authorize scopes: ["GP", "EXTERNAL"]
  @decode Proto.Calls.PendingVisitCallRequest
  def pending_visit_call(conn, _params) do
    visit_id = conn.assigns.protobuf.visit_id

    with pending_visit <- PendingVisit.get(visit_id) do
      call = Calls.PendingVisit.call_patient(pending_visit.patient_id, pending_visit.record_id)

      render(conn, "pending_visit_call.proto", %{call: call, visit: pending_visit})
    end
  end

  @authorize scope: "EXTERNAL"
  @decode Proto.Calls.DoctorPendingVisitCallRequest
  def doctor_pending_visit_call(conn, _params) do
    doctor_id = conn.assigns.current_specialist_id
    visit_id = conn.assigns.protobuf.visit_id

    with {:ok, pending_visit} <- Visits.check_if_doctor_can_call_pending_visit(visit_id) do
      call =
        Calls.DoctorPendingVisit.call_patient(
          doctor_id,
          pending_visit.patient_id,
          pending_visit.record_id
        )

      render(conn, "doctor_pending_visit_call.proto", %{call: call, visit: pending_visit})
    end
  end
end

defmodule Web.PanelApi.Calls.VisitCallView do
  use Web, :view

  def render("visit_call.proto", %{call: call, visit: visit}) do
    %Proto.Calls.VisitCallResponse{
      api_key: call.api_key,
      call_id: call.call_id,
      doctor_session_token: call.doctor_session_token,
      patient_id: call.patient_id,
      record_id: visit.record_id,
      session_id: call.session_id
    }
  end

  def render("pending_visit_call.proto", %{call: call, visit: visit}) do
    %Proto.Calls.PendingVisitCallResponse{
      api_key: call.api_key,
      call_id: call.call_id,
      gp_session_token: call.gp_session_token,
      patient_id: call.patient_id,
      record_id: visit.record_id,
      session_id: call.session_id
    }
  end

  def render("doctor_pending_visit_call.proto", %{call: call, visit: visit}) do
    %Proto.Calls.DoctorPendingVisitCallResponse{
      api_key: call.api_key,
      call_id: call.call_id,
      doctor_session_token: call.doctor_session_token,
      patient_id: call.patient_id,
      record_id: visit.record_id,
      session_id: call.session_id
    }
  end
end
