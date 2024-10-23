defmodule Web.Api.UrgentCareControllerTest do
  use Mockery
  use Web.ConnCase, async: true

  setup [:authenticate_patient]

  describe "cancel/2" do
    test "removes patient from patiens queue, adds a refund and cancels urgent care request", %{
      conn: conn,
      current_patient: current_patient
    } do
      gp = Authentication.Factory.insert(:specialist, type: "GP")
      add_patient_to_queue(current_patient, gp)

      conn = put(conn, urgent_care_path(conn, :cancel_call))

      assert response(conn, 200)
      assert {:ok, []} = UrgentCare.fetch_patients_queue(gp.id)

      {:ok, [%{canceled_at: canceled_at, payment: payment}]} =
        UrgentCare.fetch_urgent_care_requests_for_patient(current_patient.id)

      assert %UrgentCare.Payments.Refund{reason: :canceled_by_patient} =
               Postgres.Repo.get_by(UrgentCare.Payments.Refund, payment_id: payment.id)

      assert canceled_at
    end
  end

  defp add_patient_to_queue(patient, gp) do
    record = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
    {:ok, specialist_team} = Teams.create_team(2, %{})
    :ok = Teams.add_to_team(team_id: specialist_team.id, specialist_id: gp.id)
    Teams.accept_invitation(team_id: specialist_team.id, specialist_id: gp.id)

    team_ids = [specialist_team.id]
    mock(UrgentCare.AreaDispatch, [team_ids_in_area: 1], team_ids)

    UrgentCare.PatientsQueue.add_to_queue(%{
      patient_id: patient.id,
      record_id: record.id,
      patient_location: %{latitude: 10.0, longitude: 10.0},
      device_id: UUID.uuid4(),
      payment_params: %{
        transaction_reference: "transaction_reference",
        payment_method: :TELR,
        amount: "299",
        currency: "USD",
        urgent_care_request_id: UUID.uuid4()
      }
    })
  end
end
