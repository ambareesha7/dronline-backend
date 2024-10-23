defmodule Payouts.PendingWithdrawals do
  use Postgres.Service

  alias Payouts.PendingWithdrawals.PendingWithdrawal
  alias Payouts.PendingWithdrawals.Visit
  alias SpecialistProfile.Prices

  @spec create(pos_integer, pos_integer, pos_integer) :: {:ok, %PendingWithdrawal{} | nil}
  def create(patient_id, record_id, specialist_id) do
    record_id
    |> Visit.get_by_record_id()
    |> case do
      {:ok, %Visit{id: visit_id, chosen_medical_category_id: chosen_category_id}} ->
        {:ok, %{id: us_board_medical_category_id}} = Visits.fetch_us_board_medical_category()

        create_pending_withdrawal(
          %{
            patient_id: patient_id,
            record_id: record_id,
            specialist_id: specialist_id,
            visit_id: visit_id
          },
          chosen_category_id,
          us_board_medical_category_id
        )

      {:error, :not_found} ->
        {:ok, nil}
    end
  end

  @spec fetch(pos_integer) :: {:ok, [%PendingWithdrawal{}]}
  def fetch(specialist_id) do
    PendingWithdrawal
    |> join(:left, [pw], v in "visits_log", on: v.record_id == pw.record_id, as: :visit)
    |> where(specialist_id: ^specialist_id)
    |> order_by(desc: :inserted_at)
    |> select_merge([pw, v], %{
      medical_category_id: v.chosen_medical_category_id
    })
    |> Repo.fetch_all()
  end

  defp create_pending_withdrawal(
         %{
           patient_id: patient_id,
           record_id: record_id,
           visit_id: visit_id,
           specialist_id: specialist_id
         },
         chosen_medical_category_id,
         us_board_medical_category_id
       )
       when chosen_medical_category_id == us_board_medical_category_id do
    {:ok, us_board_request} =
      Visits.fetch_second_opinion_request_by_visit_id(visit_id)

    {:ok, %{price: %Money{amount: amount}}} =
      Visits.fetch_payment_by_request_id(us_board_request.id)

    PendingWithdrawal.create(%{
      patient_id: patient_id,
      record_id: record_id,
      visit_id: visit_id,
      specialist_id: specialist_id,
      amount: amount
    })
  end

  defp create_pending_withdrawal(
         %{
           patient_id: patient_id,
           record_id: record_id,
           visit_id: visit_id,
           specialist_id: specialist_id
         },
         chosen_medical_category,
         _
       ) do
    {:ok, %Prices{price_minutes_15: price}} =
      Prices.fetch_by_specialist_and_category_id(specialist_id, chosen_medical_category)

    if price == 0 do
      {:ok, nil}
    else
      PendingWithdrawal.create(%{
        patient_id: patient_id,
        record_id: record_id,
        visit_id: visit_id,
        specialist_id: specialist_id,
        amount: price
      })
    end
  end
end
