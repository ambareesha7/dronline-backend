defmodule Web.PanelApi.EMR.PendingMedicalSummariesController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    pending_summary = EMR.get_pending_medical_summary(specialist_id)

    medical_summary_draft =
      if pending_summary != nil do
        EMR.get_medical_summary_draft(pending_summary.specialist_id, pending_summary.record_id)
      else
        nil
      end

    conn
    |> render("show.proto", %{
      pending_summary: pending_summary,
      patient_id: pending_summary && pending_summary.patient_id,

      # TODO this is probably wrong approach.
      # Can be refactored so `pending_medical_summaries` have same fields as `medical_summaries`,
      # similar to `pending_visits`.
      # This would allow to just move data from `pending_medical_summaries` to `medical_summaries`
      # when Draft is finally saved.
      # Also :data should probably be turned to JSON, and :conditions, :procedures put inside.
      # Also :request_uuid may be unnecessary, as it's used only by Web frontend
      medical_summary_draft: medical_summary_draft
    })
  end
end

defmodule Web.PanelApi.EMR.PendingMedicalSummariesView do
  use Web, :view

  def render("show.proto", %{pending_summary: nil}) do
    %Proto.EMR.GetPendingMedicalSummaryResponse{}
  end

  def render("show.proto", %{
        pending_summary: pending_summary,
        medical_summary_draft: medical_summary_draft,
        patient_id: patient_id
      }) do
    %Proto.EMR.GetPendingMedicalSummaryResponse{
      pending_medical_summary: %Proto.EMR.GetPendingMedicalSummaryResponse.PendingMedicalSummary{
        record_id: pending_summary.record_id,
        patient_id: pending_summary.patient_id
      },
      patient_id: patient_id,
      medical_summary_draft: Web.View.EMR.render_medical_summary_draft(medical_summary_draft)
    }
  end
end
