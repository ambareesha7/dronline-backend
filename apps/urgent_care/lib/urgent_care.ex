defmodule UrgentCare do
  import Ecto.Query

  alias EMR.PatientRecords.PatientRecord
  alias PatientProfile.BasicInfo
  alias Postgres.Repo
  alias UrgentCare.Request

  def fetch_pending_urgent_care_request_for_patient(patient_id) do
    result =
      Request
      |> where(patient_id: ^patient_id)
      |> where([r], is_nil(r.canceled_at))
      |> where([r], is_nil(r.call_started_at))
      |> order_by(desc: :inserted_at)
      |> preload(:payment)
      |> limit(1)
      |> Repo.one()

    if is_nil(result) do
      {:error, :not_found}
    else
      {:ok, result}
    end
  end

  def fetch_urgent_care_requests_for_patient(patient_id) do
    Request
    |> where(patient_id: ^patient_id)
    |> preload(:payment)
    |> Repo.fetch_all()
  end

  def fetch_patients_queue(gm_id) do
    team_id = Teams.specialist_team_id(gm_id)
    UrgentCare.PatientsQueue.Schema.fetch_by_team_id(team_id)
  end

  def maybe_send_patient_summary_email(record_id, patient_id) do
    with {:ok, record} <- PatientRecord.fetch_by_id(record_id, patient_id),
         {:ok, auth_token_entry} <-
           Authentication.Patient.AuthTokenEntry.fetch_by_patient_id(patient_id),
         {:ok, request} <- Request.fetch_by_record_id_for_pdf_summary(record.id),
         {:ok, basic_info} <- BasicInfo.fetch_by_patient_id(patient_id) do
      Mailers.send_email(%{
        type: "URGENT_CARE_SUMMARY",
        record_id: record_id,
        token: auth_token_entry.auth_token,
        patient_email: basic_info.email,
        amount: request.payment.price.amount,
        currency: request.payment.price.currency,
        visit_date: record.closed_at,
        specialist_name: record.with_specialist_id,
        payment_date: request.payment.inserted_at
      })
    end
  end

  defdelegate closest_clinic_or_hospital(location), to: UrgentCare.AreaDispatch
end
