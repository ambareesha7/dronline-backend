defmodule EMR.PatientInvitations.AcceptInvitationTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientInvitations.AcceptInvitation

  test "saves the patient-specialist interaction after patient accepts invitation" do
    specialist = Authentication.Factory.insert(:verified_specialist)
    _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

    patient = PatientProfile.Factory.insert(:patient, phone_number: "+48532568641")
    _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

    {:ok, _account} =
      Authentication.Patient.Account.create(%{
        firebase_id: "firebase_id",
        main_patient_id: patient.id,
        phone_number: "+48532568641"
      })

    _patient_invitation =
      EMR.Factory.insert(:patient_invitation,
        specialist_id: specialist.id,
        phone_number: "+48532568641"
      )

    _ = AcceptInvitation.connect_and_send_email_for_patient_invitations(patient.id)

    assert EMR.specialist_patient_connected?(specialist.id, patient.id, false)
  end
end
