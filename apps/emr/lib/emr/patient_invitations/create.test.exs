defmodule EMR.PatientInvitations.CreateTest do
  use Postgres.DataCase, async: true
  use Oban.Testing, repo: Postgres.Repo

  import Mockery.Assertions

  describe "call/2 sends invitation emails" do
    test "create invitation when patient isn't registered" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      invitation_proto = %Proto.EMR.Invitation{phone_number: "+48532568641"}

      assert {:ok, _oban_job} =
               EMR.PatientInvitations.Create.call(specialist.id, invitation_proto)
    end

    test "create invitation, creates two jobs if email in params" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      invitation_proto_with_email = %Proto.EMR.Invitation{
        phone_number: "+48532568641",
        email: "patient@email.com"
      }

      {:ok, _oban_job} =
        EMR.PatientInvitations.Create.call(specialist.id, invitation_proto_with_email)

      assert [_first_job, _second_job] = all_enqueued(worker: Mailers.MailerJobs)

      assert %{success: 2} = Oban.drain_queue(queue: :mailers)
    end

    test "return error if registered patient exists" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      patient = PatientProfile.Factory.insert(:patient)

      {:ok, _account} =
        Authentication.Patient.Account.create(%{
          firebase_id: "firebase_id",
          main_patient_id: patient.id,
          phone_number: "+48532568641"
        })

      invitation_proto = %Proto.EMR.Invitation{phone_number: "+48532568641"}

      assert {:error, "this patient is already registered"} =
               EMR.PatientInvitations.Create.call(specialist.id, invitation_proto)
    end

    test "sends email to specialist repeatedly even if unregistered patient was already invited" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      invitation_proto = %Proto.EMR.Invitation{phone_number: "+48532568641"}

      _patient = PatientProfile.Factory.insert(:patient)

      # Send email to Specialist
      {:ok, _oban_job} = EMR.PatientInvitations.Create.call(specialist.id, invitation_proto)

      # Send email to Specialist again
      assert {:ok, _oban_job} =
               EMR.PatientInvitations.Create.call(specialist.id, invitation_proto)
    end

    test "return error if no email and phone_number was provided" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      invitation_proto = %Proto.EMR.Invitation{phone_number: "", email: ""}

      assert {:error, changeset} =
               EMR.PatientInvitations.Create.call(specialist.id, invitation_proto)

      error_msg = "at least one field is required"
      assert error_msg in errors_on(changeset).phone_number

      refute_enqueued(worker: Mailers.MailerJobs)
    end
  end

  describe "call/2 sends invitation SMS" do
    test "send SMS repeatedly even if unregistered patient was already invited" do
      specialist = Authentication.Factory.insert(:verified_specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      invitation_proto = %Proto.EMR.Invitation{phone_number: "+48532568641"}

      _patient = PatientProfile.Factory.insert(:patient)

      {:ok, _oban_job} = EMR.PatientInvitations.Create.call(specialist.id, invitation_proto)
      {:ok, _oban_job} = EMR.PatientInvitations.Create.call(specialist.id, invitation_proto)

      assert_called(Twilio.SMSClient, :send, [_, _], 2)
    end
  end
end
