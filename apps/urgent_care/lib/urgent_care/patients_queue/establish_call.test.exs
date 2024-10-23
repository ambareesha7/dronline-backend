defmodule UrgentCare.PatientsQueue.EstablishCallTest do
  use Postgres.DataCase, async: true

  alias UrgentCare.PatientsQueue.EstablishCall
  import Mockery

  describe "call/1" do
    test "adds patient to specialist's EMR and gives access to specialist to patient's basic info" do
      gp = Authentication.Factory.insert(:specialist, type: "GP")

      patient = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)
      emr_record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      add_to_queue_command = %{
        device_id: "123",
        record_id: emr_record.id,
        patient_id: patient.id,
        patient_location: %{latitude: 10.0, longitude: 10.0},
        payment_params: %{
          amount: "299",
          currency: "USD",
          transaction_reference: "transaction_reference",
          payment_method: :TELR
        }
      }

      team_ids = ["99", "08", "10"]
      mock(UrgentCare.AreaDispatch, [team_ids_in_area: 1], team_ids)

      %UrgentCare.PatientsQueue.Schema{} =
        UrgentCare.PatientsQueue.add_to_queue(add_to_queue_command)

      EstablishCall.call(%{patient_id: patient.id, gp_id: gp.id, call_id: "asdfg"})

      assert EMR.specialist_patient_connected?(gp.id, patient.id, false)

      assert {:ok, [%{call_started_at: call_started_at, canceled_at: nil}]} =
               UrgentCare.fetch_urgent_care_requests_for_patient(patient.id)

      assert call_started_at
    end
  end
end
