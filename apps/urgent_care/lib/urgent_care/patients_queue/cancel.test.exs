defmodule UrgentCare.PatientsQueue.CancelTest do
  use Postgres.DataCase, async: true

  alias UrgentCare.PatientsQueue.Cancel

  describe "call/2" do
    setup do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)
      patient = PatientProfile.Factory.insert(:patient)
      emr_record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      {:ok, team} = Teams.create_team(:rand.uniform(1000), %{})
      :ok = Teams.add_to_team(team_id: team.id, specialist_id: specialist.id)
      Teams.accept_invitation(team_id: team.id, specialist_id: specialist.id)
      Application.put_env(:urgent_care, :default_clinic_id, Integer.to_string(team.id))

      %UrgentCare.PatientsQueue.Schema{} =
        UrgentCare.PatientsQueue.add_to_queue(%{
          patient_id: patient.id,
          record_id: emr_record.id,
          patient_location: %{latitude: 10.0, longitude: 10.0},
          device_id: "123",
          payment_params: %{
            transaction_reference: "transaction_reference",
            payment_method: :TELR,
            amount: "299",
            currency: "USD",
            urgent_care_request_id: UUID.uuid4()
          }
        })

      {:ok, [pending_urgent_care_request]} =
        UrgentCare.fetch_urgent_care_requests_for_patient(patient.id)

      %{
        specialist: specialist,
        patient: patient,
        urgent_care_request_id: pending_urgent_care_request.id,
        payment_id: pending_urgent_care_request.payment.id
      }
    end

    test "removes patient from patiens queue, adds a refund and cancels urgent care request", %{
      patient: patient,
      specialist: specialist,
      payment_id: payment_id
    } do
      {:ok, _} = Cancel.call(%{patient_id: patient.id, reason: :canceled_by_patient})

      assert {:ok, []} = UrgentCare.fetch_patients_queue(specialist.id)

      assert %UrgentCare.Payments.Refund{payment_id: ^payment_id, reason: :canceled_by_patient} =
               Repo.get_by(UrgentCare.Payments.Refund, payment_id: payment_id)

      {:ok, [%{canceled_at: canceled_at}]} =
        UrgentCare.fetch_urgent_care_requests_for_patient(patient.id)

      assert canceled_at
    end

    test "adds a refund and cancels urgent care request when patient is already removed from queue",
         %{patient: patient, payment_id: payment_id} do
      UrgentCare.PatientsQueue.remove_from_queue(patient.id)

      {:ok, _} = Cancel.call(%{patient_id: patient.id, reason: :canceled_by_patient})

      assert %UrgentCare.Payments.Refund{payment_id: ^payment_id, reason: :canceled_by_patient} =
               Repo.get_by(UrgentCare.Payments.Refund,
                 payment_id: payment_id
               )

      {:ok, [%{canceled_at: canceled_at}]} =
        UrgentCare.fetch_urgent_care_requests_for_patient(patient.id)

      assert canceled_at
    end

    test "returns error when request is already canceled", %{
      patient: patient,
      urgent_care_request_id: urgent_care_request_id
    } do
      {:ok, _} =
        UrgentCare.Request.cancel(urgent_care_request_id, DateTime.utc_now())

      {:error, :no_pending_urgent_care_request} =
        Cancel.call(%{patient_id: patient.id, reason: :canceled_by_patient})
    end

    test "returns error when refund is already created", %{
      patient: patient,
      payment_id: payment_id
    } do
      UrgentCare.Payments.create_refund(%{
        reason: :canceled_automatically,
        payment_id: payment_id
      })

      {:error, :refund_already_created} =
        Cancel.call(%{patient_id: patient.id, reason: :canceled_by_patient})
    end

    test "after cancelling, it's possible to create another urgent care request", %{
      patient: %{id: patient_id},
      specialist: specialist
    } do
      {:ok, _} = Cancel.call(%{patient_id: patient_id, reason: :canceled_by_patient})

      emr_record = EMR.Factory.insert(:automatic_record, patient_id: patient_id)

      %UrgentCare.PatientsQueue.Schema{} =
        UrgentCare.PatientsQueue.add_to_queue(%{
          device_id: "123",
          record_id: emr_record.id,
          patient_id: patient_id,
          patient_location: %{latitude: 10.0, longitude: 10.0},
          payment_params: %{
            amount: "299",
            currency: "USD",
            transaction_reference: "transaction_reference",
            payment_method: :TELR
          }
        })

      {:ok, [%{canceled_at: previous_request_canceled_at}, %{canceled_at: nil}]} =
        UrgentCare.fetch_urgent_care_requests_for_patient(patient_id)

      assert previous_request_canceled_at
      assert {:ok, [%{patient_id: ^patient_id}]} = UrgentCare.fetch_patients_queue(specialist.id)
    end
  end
end
