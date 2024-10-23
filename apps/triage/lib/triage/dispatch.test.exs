defmodule Triage.DispatchTest do
  use Postgres.DataCase, async: true

  defp prepare_pending_dispatch do
    patient = PatientProfile.Factory.insert(:patient)
    gp = Authentication.Factory.insert(:specialist, type: "GP")
    record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

    cmd = %Triage.Commands.RequestDispatchToPatient{
      patient_id: patient.id,
      patient_location_address: %{
        city: "Dubai",
        country: "United Arab Emirates",
        building_number: "1",
        postal_code: "2",
        street_name: "3"
      },
      record_id: record.id,
      region: "united-arab-emirates-dubai",
      request_id: UUID.uuid4(),
      requester_id: gp.id
    }

    Triage.request_dispatch_to_patient(cmd)
  end

  defp prepare_ongoing_dispatch do
    {:ok, pending_dispatch} = prepare_pending_dispatch()
    nurse_id = Authentication.Factory.insert(:specialist, type: "NURSE").id

    cmd = %Triage.Commands.TakePendingDispatch{
      nurse_id: nurse_id,
      request_id: pending_dispatch.request_id
    }

    Triage.take_pending_dispatch(cmd)
  end

  defp prepare_ended_dispatch do
    {:ok, ongoing_dispatch} = prepare_ongoing_dispatch()

    cmd = %Triage.Commands.EndDispatch{
      nurse_id: ongoing_dispatch.nurse_id,
      request_id: ongoing_dispatch.request_id
    }

    Triage.end_dispatch(cmd)
  end

  describe "fetch_by_request_id/1" do
    test "returns CurrentDispatch struct when dispatch is pending" do
      {:ok, pending_dispatch} = prepare_pending_dispatch()

      assert {:ok, %Triage.CurrentDispatch{} = fetched_dispatch} =
               Triage.Dispatch.fetch_by_request_id(pending_dispatch.request_id)

      assert fetched_dispatch.request_id == pending_dispatch.request_id
    end

    test "returns CurrentDispatch struct when dispatch is ongoing" do
      {:ok, ongoing_dispatch} = prepare_ongoing_dispatch()

      assert {:ok, %Triage.CurrentDispatch{} = fetched_dispatch} =
               Triage.Dispatch.fetch_by_request_id(ongoing_dispatch.request_id)

      assert fetched_dispatch.request_id == ongoing_dispatch.request_id
    end

    test "returns EndedDispatch struct when dispatch is ended" do
      {:ok, ended_dispatch} = prepare_ended_dispatch()

      assert {:ok, %Triage.EndedDispatch{} = fetched_dispatch} =
               Triage.Dispatch.fetch_by_request_id(ended_dispatch.request_id)

      assert fetched_dispatch.request_id == ended_dispatch.request_id
    end

    test "returns :not_found error when request_id is invalid" do
      assert {:error, :not_found} = Triage.Dispatch.fetch_by_request_id("invalid")
    end
  end
end
