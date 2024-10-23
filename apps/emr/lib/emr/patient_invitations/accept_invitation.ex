defmodule EMR.PatientInvitations.AcceptInvitation do
  alias EMR.PatientInvitations.Patient
  alias EMR.PatientInvitations.PatientInvitation
  alias EMR.SpecialistPatientConnections.SpecialistPatientConnection

  def connect_and_send_email_for_patient_invitations(patient_id) do
    {:ok, patient} = Patient.fetch_by_id(patient_id)
    {:ok, patient_basic_info} = PatientProfile.fetch_basic_info(patient.id)

    patient_invitations =
      PatientInvitation.fetch_by_phone_number_or_email(
        patient.phone_number,
        patient_basic_info.email
      )

    patient_invitations
    |> Enum.each(fn invitation ->
      process_invitation(invitation, patient, patient_basic_info)
    end)
  end

  defp process_invitation(invitation, patient, patient_basic_info) do
    {:ok, specialist_data} = EMR.SpecialistData.fetch_by_id(invitation.specialist_id)

    with {:ok, _connection} <-
           SpecialistPatientConnection.create(invitation.specialist_id, patient.id),
         {:ok, _job} <- create_mailer_job(specialist_data, patient, patient_basic_info) do
      :ok
    end
  end

  defp create_mailer_job(specialist_data, patient, patient_basic_info) do
    %{
      type: "PATIENT_ACCEPTED_INVITATION",
      specialist_email: specialist_data.specialist.email,
      patient_data: %{
        email: patient_basic_info.email,
        first_name: patient_basic_info.first_name,
        last_name: patient_basic_info.last_name,
        phone_number: patient.phone_number
      }
    }
    |> Mailers.MailerJobs.new()
    |> Oban.insert()
  end
end
