defmodule Visits.Payments do
  alias Postgres.Repo
  alias UrgentCare.Payments.Payment, as: UrgentCarePayment
  alias Visits.USBoard.SecondOpinionRequestPayment
  alias Visits.Visit.Payment
  alias Visits.Visit.Payment.Refund

  defdelegate fetch_refund_record_id(record_id),
    to: Refund,
    as: :fetch_by_record_id

  def create(params) do
    params = add_price_to_params(params)

    %Payment{} |> Payment.changeset(params) |> Repo.insert()
  end

  def refund(params) do
    %Refund{} |> Refund.changeset(params) |> Repo.insert()
  end

  def create_for_us_board(params, us_board_request_id) do
    params =
      params
      |> add_price_to_params()
      |> Map.put(:us_board_second_opinion_request_id, us_board_request_id)

    %SecondOpinionRequestPayment{}
    |> SecondOpinionRequestPayment.changeset(params)
    |> Repo.insert()
  end

  def fetch_by_record_and_patient_id(record_id, patient_id) do
    payment =
      case EMR.PatientRecords.PatientRecord.fetch_by_id(record_id, patient_id) do
        {:ok, record} ->
          if record.type == :US_BOARD do
            SecondOpinionRequestPayment.fetch_by_us_board_second_opinion_request_id(
              record.us_board_request_id
            )
          else
            maybe_return_urgent_care_payment(record_id)
          end

        {:error, :not_found} ->
          nil
      end

    {:ok, maybe_return_empty_payment(payment)}
  end

  defp maybe_return_urgent_care_payment(record_id) do
    case Payment.by_visit_id(record_id) do
      nil -> UrgentCarePayment.fetch_by_urgent_care_patient_record_id(record_id)
      record -> record
    end
  end

  def fetch_by_record_id(record_id) do
    payment =
      record_id
      |> Payment.by_visit_id()
      |> maybe_return_empty_payment()

    {:ok, payment}
  end

  def assign_to_us_board_visit(us_board_request_id, visit_record_id) do
    SecondOpinionRequestPayment
    |> Repo.get_by(%{us_board_second_opinion_request_id: us_board_request_id})
    |> Ecto.Changeset.change(visit_id: visit_record_id)
    |> Repo.update()
  end

  defp add_price_to_params(%{amount: amount, currency: currency} = params)
       when not is_nil(amount) and not is_nil(currency) do
    Map.put(params, :price, Money.new(String.to_integer(amount), parse_currency(currency)))
  end

  defp add_price_to_params(params) do
    Map.put(params, :price, Money.new(0, :USD))
  end

  defp parse_currency(""), do: :USD
  defp parse_currency(currency), do: currency

  defp maybe_return_empty_payment(nil) do
    %Visits.Visit.Payment{price: %Money{amount: nil, currency: nil}}
  end

  defp maybe_return_empty_payment(payment), do: payment
end
