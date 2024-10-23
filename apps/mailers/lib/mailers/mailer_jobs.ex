defmodule Mailers.MailerJobs do
  use Oban.Worker, queue: :mailers, max_attempts: 5
  import Mockery.Macro

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    if send_email(args) == :ok do
      :ok
    else
      _ = Sentry.Context.set_extra_context(%{args: args})

      _ =
        Sentry.capture_message(
          "Mailer: failed to send email",
          level: "error"
        )

      {:error, :cannot_send_email}
    end
  end

  defp send_email(%{
         "type" => "SPECIALIST_VERIFICATION_LINK",
         "specialist_email" => specialist_email,
         "specialist_type" => specialist_type,
         "verification_token" => verification_token
       }) do
    Mailers.AuthenticationMailer.send_verification_link(
      specialist_email,
      specialist_type,
      verification_token
    )
  end

  defp send_email(%{"type" => "SPECIALIST_SIGNUP_WARNING", "specialist_email" => specialist_email}) do
    Mailers.AuthenticationMailer.send_warning_info(specialist_email)
  end

  defp send_email(%{
         "type" => "SPECIALIST_PASSWORD_RECOVERY_LINK",
         "specialist_email" => specialist_email,
         "password_recovery_token" => password_recovery_token
       }) do
    Mailers.AuthenticationMailer.send_password_recovery_link(
      specialist_email,
      password_recovery_token
    )
  end

  defp send_email(%{
         "type" => "SPECIALIST_PASSWORD_CHANGE_LINK",
         "specialist_email" => specialist_email,
         "password_change_confirmation_token" => password_change_confirmation_token
       }) do
    Mailers.AuthenticationMailer.send_password_change_link(
      specialist_email,
      password_change_confirmation_token
    )
  end

  defp send_email(%{
         "type" => "INTERNAL_SPECIALIST_CREATION",
         "specialist_email" => specialist_email,
         "password_recovery_token" => password_recovery_token
       }) do
    Mailers.AdminMailer.send_account_creation_message(specialist_email, password_recovery_token)
  end

  defp send_email(%{
         "type" => "INTERNAL_SPECIALIST_ADDED_TO_TEAM",
         "specialist_email" => specialist_email,
         "password_recovery_token" => password_recovery_token
       }) do
    Mailers.AdminMailer.send_account_creation_by_team_admin_message(
      specialist_email,
      password_recovery_token
    )
  end

  defp send_email(%{
         "type" => "EXTERNAL_SPECIALIST_APPROVAL",
         "specialist_email" => specialist_email
       }) do
    Mailers.AdminMailer.send_account_approval_message(specialist_email)
  end

  defp send_email(%{
         "type" => "EXTERNAL_SPECIALIST_REJECTION",
         "specialist_email" => specialist_email
       }) do
    Mailers.AdminMailer.send_account_rejection_message(specialist_email)
  end

  defp send_email(%{
         "type" => "PATIENT_ASSIGN_MEDICATIONS",
         "patient_email" => patient_email,
         "specialist_data" => specialist_data,
         "dynamic_link" => dynamic_link
       }) do
    Mailers.EMRMailer.send_patient_assigned_meds(patient_email, specialist_data, dynamic_link)
  end

  defp send_email(%{
         "type" => "PATIENT_INVITATION",
         "patient_email" => patient_email,
         "specialist_data" => specialist_data,
         "dynamic_link" => dynamic_link
       }) do
    Mailers.EMRMailer.send_patient_invitation(patient_email, specialist_data, dynamic_link)
  end

  defp send_email(%{
         "type" => "PATIENT_INVITED",
         "specialist_email" => specialist_email,
         "invitation" => invitation
       }) do
    Mailers.EMRMailer.send_patient_invited(specialist_email, invitation)
  end

  defp send_email(%{
         "type" => "PATIENT_ACCEPTED_INVITATION",
         "specialist_email" => specialist_email,
         "patient_data" => patient_data
       }) do
    Mailers.EMRMailer.send_patient_accepted_invitation(specialist_email, patient_data)
  end

  defp send_email(%{
         "type" => "URGENT_CARE_SUMMARY",
         "patient_email" => patient_email,
         "record_id" => record_id,
         "token" => token,
         "amount" => amount,
         "currency" => currency,
         "visit_date" => visit_date,
         "payment_date" => payment_date,
         "specialist_name" => specialist_name
       }) do
    summary_pdf = mockable(EMR).generate_record_pdf_for_patient(record_id, token)

    Mailers.UrgentCareMailer.send_patient_urgent_care_summary(%{
      patient_email: patient_email,
      summary_pdf: summary_pdf,
      amount: amount,
      currency: currency,
      visit_date: visit_date,
      payment_date: payment_date,
      specialist_name: specialist_name
    })
  end

  defp send_email(%{
         "type" => "NEW_US_BOARD_REQUEST"
       }) do
    Mailers.UsBoardMailer.send_admin_new_request()
  end

  defp send_email(%{
         "type" => "SPECIALIST_ASSIGNED_TO_US_BOARD_REQUEST",
         "specialist_email" => specialist_email
       }) do
    Mailers.UsBoardMailer.specialist_assigned_to_request(specialist_email)
  end

  defp send_email(%{
         "type" => "SPECIALIST_ACCEPTED_US_BOARD_REQUEST",
         "specialist_name" => specialist_name
       }) do
    Mailers.UsBoardMailer.specialist_accepted_request(%{specialist_name: specialist_name})
  end

  defp send_email(%{
         "type" => "SPECIALIST_REJECTED_US_BOARD_REQUEST"
       }) do
    Mailers.UsBoardMailer.specialist_rejected_request()
  end

  defp send_email(%{
         "type" => "PATIENT_SCHEDULED_US_BOARD_CALL",
         "specialist_email" => specialist_email
       }) do
    Mailers.UsBoardMailer.patient_scheduled_call(specialist_email: specialist_email)
  end

  defp send_email(%{
         "type" => "PATIENT_US_BOARD_REQUEST_CONFIRMATION",
         "patient_email" => patient_email,
         "us_board_request_id" => us_board_request_id
       }) do
    Mailers.UsBoardMailer.patient_request_confirmation(patient_email, us_board_request_id)
  end

  defp send_email(%{
         "type" => "SPECIALIST_SET_AVAILABILITY",
         "patient_email" => patient_email
       }) do
    Mailers.UsBoardMailer.specialist_set_availability(patient_email)
  end

  defp send_email(%{
         "type" => "SPECIALIST_SUBMITTED_SECOND_OPINION",
         "patient_email" => patient_email,
         "us_board_request_id" => us_board_request_id,
         "specialist_name" => specialist_name
       }) do
    Mailers.UsBoardMailer.send_patient_second_opinion(%{
      patient_email: patient_email,
      us_board_request_id: us_board_request_id,
      specialist_name: specialist_name
    })
  end

  defp send_email(%{
         "type" => "VISIT_BOOKING_CONFIRMATION",
         "patient_email" => patient_email,
         "amount" => amount,
         "currency" => currency,
         "visit_date" => visit_date,
         "payment_date" => payment_date,
         "specialist_name" => specialist_name,
         "medical_category_name" => medical_category_name
       }) do
    Mailers.VisitMailer.send_visit_confirmation(%{
      patient_email: patient_email,
      amount: amount,
      currency: currency,
      visit_date: visit_date,
      payment_date: payment_date,
      specialist_name: specialist_name,
      medical_category_name: medical_category_name
    })
  end

  defp send_email(_job) do
    raise "unknown job"
  end
end
