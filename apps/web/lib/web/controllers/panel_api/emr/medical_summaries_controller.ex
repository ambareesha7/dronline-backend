defmodule Web.PanelApi.EMR.MedicalSummariesController do
  use Conductor
  use Web, :controller

  alias EMR.PatientRecords.Autoclose.Saga, as: AutocloseSaga

  action_fallback Web.FallbackController

  plug Web.Plugs.VerifySpecialistPatientConnection, param_name: "patient_id"

  @authorize scopes: [
               "GP",
               "NURSE",
               {"EXTERNAL", "GOLD"},
               {"EXTERNAL", "PLATINUM"}
             ]
  def index(conn, params) do
    record_id = params["record_id"]

    with {:ok, medical_summaries} <- EMR.fetch_medical_summaries(record_id) do
      specialists_generic_data =
        medical_summaries
        |> Enum.map(& &1.specialist_id)
        |> Web.SpecialistGenericData.get_by_ids()

      render(conn, "index.proto", %{
        medical_summaries: medical_summaries,
        specialists_generic_data: specialists_generic_data
      })
    end
  end

  @authorize scopes: ["GP", "NURSE", "EXTERNAL"]
  def latest_for_specialist(conn, params) do
    record_id = params["record_id"]
    specialist_id = conn.assigns.current_specialist_id

    medical_summary = EMR.fetch_latest_summary_for_specialist(specialist_id, record_id)

    render(conn, "show_latest.proto", %{
      medical_summary: medical_summary
    })
  end

  @authorize scopes: ["GP", "NURSE", "EXTERNAL"]
  @decode Proto.EMR.AddMedicalSummaryRequest
  def create(conn, params) do
    record_id = String.to_integer(params["record_id"])

    specialist_id = conn.assigns.current_specialist_id

    %{
      skip_patient_notification: skip_patient_notification
    } = proto = conn.assigns.protobuf

    request_uuid = request_uuid(conn)

    with {:ok, summary} <-
           EMR.create_medical_summary(specialist_id, record_id, proto, request_uuid) do
      EMR.resolve_pending_medical_summary(record_id, specialist_id)

      # TODO replace this workaround when patient_id will be added as param to the request
      # and move AutocloseSaga request call to resolve_pending_medical_summary function body
      patient_id = Postgres.Repo.get(EMR.PatientRecords.PatientRecord, record_id).patient_id

      :ok = AutocloseSaga.register_provided_medical_summary(patient_id, record_id, specialist_id)
      {:ok, _} = Payouts.create_pending_withdrawal(patient_id, record_id, specialist_id)

      Visits.maybe_move_us_board_request_to_done(record_id)

      UrgentCare.maybe_send_patient_summary_email(record_id, patient_id)

      if !skip_patient_notification do
        _ =
          NotificationsWrite.notify_patient_about_record_change(
            record_id,
            patient_id,
            specialist_id,
            medical_summary_id: summary.id
          )
      end

      resp(conn, 201, "")
    end
  end

  @authorize scopes: ["GP", "NURSE", "EXTERNAL"]
  @decode Proto.EMR.AddMedicalSummaryDraftRequest
  def create_draft(conn, params) do
    record_id = String.to_integer(params["record_id"])

    specialist_id = conn.assigns.current_specialist_id
    proto = conn.assigns.protobuf

    with {:ok, _summary} <-
           EMR.create_medical_summary_draft(specialist_id, record_id, proto) do
      resp(conn, 201, "")
    end
  end

  @authorize scopes: ["GP", "NURSE", "EXTERNAL"]
  def skip(conn, params) do
    record_id = String.to_integer(params["record_id"])
    specialist_id = conn.assigns.current_specialist_id

    EMR.resolve_pending_medical_summary(record_id, specialist_id)
    EMR.remove_medical_summary_draft(specialist_id, record_id)

    resp(conn, 200, "")
  end

  @authorize scopes: ["GP", "NURSE", "EXTERNAL"]
  def show_draft(conn, params) do
    record_id = String.to_integer(params["record_id"])
    specialist_id = conn.assigns.current_specialist_id

    medical_summary_draft = EMR.get_medical_summary_draft(specialist_id, record_id)

    render(conn, "show_draft.proto", %{
      medical_summary_draft: medical_summary_draft
    })
  end

  defp request_uuid(conn) do
    # We need this to prevent this code from crashing if the client doesn't
    # provide an UUID.
    # We can probably remove that after the frontend is updated to reflect that
    # change.
    uuid = conn.assigns.protobuf.request_uuid

    if uuid == "" do
      UUID.uuid4()
    else
      uuid
    end
  end
end

defmodule Web.PanelApi.EMR.MedicalSummariesView do
  use Web, :view

  def render("index.proto", %{
        medical_summaries: medical_summaries,
        specialists_generic_data: specialists_generic_data
      }) do
    %Proto.EMR.GetMedicalSummariesResponse{
      medical_summaries:
        Enum.map(
          medical_summaries,
          &Web.View.EMR.render_medical_summary/1
        ),
      specialists: Enum.map(specialists_generic_data, &Web.View.Generics.render_specialist/1)
    }
  end

  def render("show_draft.proto", %{
        medical_summary_draft: medical_summary_draft
      }) do
    %Proto.EMR.ShowMedicalSummaryDraftResponse{
      medical_summary_draft: Web.View.EMR.render_medical_summary_draft(medical_summary_draft)
    }
  end

  def render("show_latest.proto", %{
        medical_summary: medical_summary
      }) do
    %Proto.EMR.GetLatestMedicalSummaryResponse{
      medical_summary: Web.View.EMR.render_latest_medical_summary(medical_summary)
    }
  end
end
