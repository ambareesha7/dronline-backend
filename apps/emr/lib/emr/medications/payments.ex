defmodule EMR.Medications.Payments do
  require Logger
  use Postgres.Service
  import Mockery.Macro

  alias EMR.Medications.Payment
  alias PaymentsApi.Client.CheckPaymentStatus

  defmacrop landing_payment_api do
    quote do: mockable(PaymentsApi.Client.Payment, by: PaymentsApi.Client.PaymentMock)
  end

  # TODO: write tests
  def call(params) do
    case get_payment_url(params) do
      {:ok, %{payment_url: result, ref: ref}} ->
        Logger.info("Medication order payment result: #{inspect(result)} ref: #{inspect(ref)}")
        {:ok, result, ref}

      {:error, failed_operation, reason, _changes_so_far} ->
        Logger.warning(
          "Medication order payment error: #{inspect(reason)} ref: #{inspect(failed_operation)}"
        )

        {:error, reason}
    end
  end

  defp get_payment_url(%{
         host: host,
         patient: patient,
         medication_order_id: medication_order_id,
         amount: amount,
         currency: currency,
         description: description
       }) do
    payment_params = %{
      ref: medication_order_id,
      amount: amount,
      currency: currency,
      description: description,
      host: host,
      user_data: %{
        email: patient.email,
        first_name: patient.first_name,
        last_name: patient.last_name
      }
    }

    landing_payment_api().get_payment_url(payment_params)
  end

  # not tested yet, this function for admin panel
  def get_payment_status_response(ref) do
    body = CheckPaymentStatus.prepare_check_request_body(ref)

    # refer this module Membership.Subscription.Verify
    mockable(CheckPaymentStatus).send(body)
  end

  def create(params) do
    params = Map.put(params, :price, Money.new(params.amount, params.currency))

    %Payment{}
    |> Payment.changeset(params)
    |> Repo.insert()
  end

  # TODO: write tests
  def update(medication_order_id, params) do
    case fetch_by_medication_order_id(medication_order_id) do
      nil ->
        {:error, :not_found}

      payment ->
        payment
        |> Payment.uppdate_changeset(params)
        |> Repo.update()
    end
  end

  def fetch_by_medications_bundle_id(medications_bundle_id) do
    Payment
    |> where(medications_bundle_id: ^medications_bundle_id)
    |> Repo.one()
  end

  # TODO: write tests
  def fetch_by_medication_order_id(medication_order_id) do
    Repo.one(from p in Payment, where: p.medication_order_id == ^medication_order_id, limit: 1)
  end

  def fetch_by_medications_bundle_ids(medications_bundle_ids) do
    Payment
    |> where([p], p.medications_bundle_id in ^medications_bundle_ids)
    |> Repo.all()
  end

  def list_all_payments do
    Repo.all(Payment)
  end
end
