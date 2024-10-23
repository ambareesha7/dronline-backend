defmodule Payouts.PendingWithdrawalsTest do
  use Postgres.DataCase, async: true

  alias Payouts.PendingWithdrawals
  alias Payouts.PendingWithdrawals.PendingWithdrawal

  setup do
    %{id: specialist_id} = Authentication.Factory.insert(:verified_and_approved_external)
    %{id: medical_category_id} = SpecialistProfile.Factory.insert(:medical_category)
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)

    SpecialistProfile.update_medical_categories([medical_category_id], specialist_id)

    {:ok,
     specialist_id: specialist_id,
     medical_category_id: medical_category_id,
     patient_id: patient_id}
  end

  describe "create/3" do
    test "creates Pending Withdrawal if Record has associated Visit", %{
      specialist_id: specialist_id,
      medical_category_id: medical_category_id,
      patient_id: patient_id
    } do
      _us_board_medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "U.S Board Second Opinion")

      timeline =
        EMR.Factory.insert(:visit_record, patient_id: patient_id, specialist_id: specialist_id)

      _visit =
        Visits.Factory.insert(:ended_visit,
          specialist_id: specialist_id,
          patient_id: patient_id,
          chosen_medical_category_id: medical_category_id,
          record_id: timeline.id
        )

      _prices =
        SpecialistProfile.Factory.insert(:prices, %{
          specialist_id: specialist_id,
          medical_category_id: medical_category_id,
          price_minutes_15: 99
        })

      assert {:ok,
              %PendingWithdrawal{
                amount: 99
              }} = PendingWithdrawals.create(patient_id, timeline.id, specialist_id)

      # Ignore repeated request for same timeline.id
      assert {:ok,
              %PendingWithdrawal{
                amount: 99
              }} = PendingWithdrawals.create(patient_id, timeline.id, specialist_id)

      assert [_] = Repo.all(PendingWithdrawal)
    end

    test "does nothing if Record doesn't have associated Visit", %{
      specialist_id: specialist_id,
      medical_category_id: medical_category_id,
      patient_id: patient_id
    } do
      _us_board_medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "U.S Board Second Opinion")

      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient_id)

      _prices =
        SpecialistProfile.Factory.insert(:prices, %{
          specialist_id: specialist_id,
          medical_category_id: medical_category_id,
          price_minutes_15: 99
        })

      assert {:ok, nil} = PendingWithdrawals.create(patient_id, timeline.id, specialist_id)
      refute Repo.one(PendingWithdrawal)
    end

    test "creates pending Withdrawal for us board", %{
      patient_id: patient_id,
      specialist_id: specialist_id
    } do
      us_board_medical_category =
        SpecialistProfile.Factory.insert(:medical_category, name: "U.S Board Second Opinion")

      {:ok, request} =
        Visits.request_us_board_second_opinion(%{
          patient_id: patient_id,
          patient_description: "Help me!",
          patient_email: "other@email.com",
          files: [%{path: "/file2.com"}],
          status: "requested",
          transaction_reference: "5678",
          payment_method: "telr"
        })

      %{id: timeline_id} =
        EMR.Factory.insert(:us_board_record,
          patient_id: patient_id,
          specialist_id: specialist_id,
          us_board_request_id: request.id
        )

      visit =
        Visits.Factory.insert(:ended_visit,
          specialist_id: specialist_id,
          patient_id: patient_id,
          chosen_medical_category_id: us_board_medical_category.id,
          record_id: timeline_id
        )

      request
      |> Ecto.Changeset.change(%{visit_id: visit.id})
      |> Postgres.Repo.update()

      assert {:ok,
              %PendingWithdrawal{
                record_id: ^timeline_id,
                patient_id: ^patient_id,
                specialist_id: ^specialist_id,
                amount: 499
              }} = PendingWithdrawals.create(patient_id, timeline_id, specialist_id)
    end
  end

  describe "fetch/1" do
    test "fetches Pending Withdrawals for given Specialist", %{
      specialist_id: specialist_id,
      medical_category_id: medical_category_id,
      patient_id: patient_id
    } do
      _prices =
        SpecialistProfile.Factory.insert(:prices, %{
          specialist_id: specialist_id,
          medical_category_id: medical_category_id,
          price_minutes_15: 99
        })

      visit_1 =
        Visits.Factory.insert(:ended_visit,
          specialist_id: specialist_id,
          patient_id: patient_id,
          chosen_medical_category_id: medical_category_id,
          record_id: 10
        )

      _pending_withdrawal_1 =
        Payouts.Factory.insert(:pending_withdrawal,
          patient_id: patient_id,
          record_id: 10,
          visit_id: visit_1.id,
          specialist_id: specialist_id,
          medical_category_id: medical_category_id,
          amount: 99
        )

      visit_2 =
        Visits.Factory.insert(:ended_visit,
          specialist_id: specialist_id,
          patient_id: patient_id,
          chosen_medical_category_id: medical_category_id,
          record_id: 11
        )

      _pending_withdrawal_2 =
        Payouts.Factory.insert(:pending_withdrawal,
          patient_id: patient_id,
          record_id: 11,
          visit_id: visit_2.id,
          specialist_id: specialist_id,
          amount: 99
        )

      assert {:ok,
              [
                %{
                  record_id: 11,
                  amount: 99,
                  medical_category_id: ^medical_category_id
                },
                %{
                  record_id: 10,
                  amount: 99,
                  medical_category_id: ^medical_category_id
                }
              ]} = PendingWithdrawals.fetch(specialist_id)
    end
  end
end
