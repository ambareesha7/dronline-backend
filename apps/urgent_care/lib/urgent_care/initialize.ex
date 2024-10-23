defmodule UrgentCare.Initialize do
  import Mockery.Macro

  alias UrgentCare.Request

  @urgent_care_currency "AED"
  @urgent_care_amount 299

  defmacrop landing_payment_api do
    quote do: mockable(PaymentsApi.Client.Payment, by: PaymentsApi.Client.PaymentMock)
  end

  def call(params) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:params, fn _, _ -> {:ok, params} end)
    |> Ecto.Multi.run(:urgent_care_request, &insert_urgent_care_request/2)
    |> Ecto.Multi.run(:get_payment_url, &get_payment_url/2)
    |> Postgres.Repo.transaction()
    |> case do
      {:ok, %{get_payment_url: result}} ->
        {:ok, result}

      {:error, _failed_operation, reason, _changes_so_far} ->
        {:error, reason}
    end
  end

  defp insert_urgent_care_request(_, %{params: %{patient: params}}) do
    Request.create(params)
  end

  defp get_payment_url(_, %{
         params: %{host: host, patient: patient},
         urgent_care_request: urgent_care_request
       }) do
    payment_params = %{
      ref: urgent_care_request.id,
      amount: urgent_care_amount(patient.patient_email),
      currency: @urgent_care_currency,
      description: "Urgent Care Request",
      host: host,
      user_data: %{
        email: patient.patient_email,
        first_name: patient.first_name,
        last_name: patient.last_name
      }
    }

    with {:ok, %{payment_url: payment_url}} <-
           landing_payment_api().get_payment_url(payment_params) do
      {:ok, %{urgent_care_request_id: urgent_care_request.id, payment_url: payment_url}}
    end
  end

  # reduce amount to this email
  defp urgent_care_amount("ravin@dronline.ai"), do: "1"

  defp urgent_care_amount(_patient_email),
    do: @urgent_care_amount
end
