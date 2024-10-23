defmodule UrgentCare.PatientsQueue.AddTest do
  use Postgres.DataCase, async: true

  alias UrgentCare.AreaDispatch
  alias UrgentCare.PatientsQueue.Add

  import Mockery

  test "urgent care request and payment is created" do
    patient_id = 1

    emr_record = EMR.Factory.insert(:automatic_record, patient_id: patient_id)

    command = %{
      device_id: "123",
      record_id: emr_record.id,
      patient_id: patient_id,
      payment_params: %{
        amount: "299",
        currency: "USD",
        transaction_reference: "transaction_reference",
        payment_method: :TELR
      }
    }

    assert %{patient_id: ^patient_id} = Add.call(command)
  end

  test "urgent care request, patient_record, and payment is created when record_id is null" do
    patient_id = 1

    command = %{
      device_id: "123",
      record_id: nil,
      patient_id: patient_id,
      payment_params: %{
        amount: "299",
        currency: "USD",
        transaction_reference: "transaction_reference",
        payment_method: :TELR
      }
    }

    assert %{patient_id: ^patient_id} = Add.call(command)
  end

  test "returns urgent care request validation error when patient_id is nil" do
    command = %{
      device_id: "123",
      record_id: 3,
      patient_id: nil,
      payment_params: %{
        payment_method: :TELR,
        amount: "299",
        currency: "USD",
        transaction_reference: "transaction_reference"
      }
    }

    team_ids = [99, 08, 10]
    mock(AreaDispatch, [team_ids_in_area: 1], team_ids)

    assert {:error, "patient_id can't be blank"} = Add.call(command)
  end
end
