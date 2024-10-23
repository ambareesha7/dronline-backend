defmodule Payouts.Factory do
  defp credentials_default_params do
    %{
      iban: "1112223333",
      name: "name",
      address: "address",
      bank_name: "bank_name",
      bank_address: "bank_address",
      bank_swift_code: "bank_swift_code",
      bank_routing_number: "bank_routing_number"
    }
  end

  def insert(:credentials, params) do
    params = Map.merge(credentials_default_params(), Enum.into(params, %{}))

    {:ok, credentials} = Payouts.Credentials.update(params, params.specialist_id)

    credentials
  end

  def insert(:pending_withdrawal, params) do
    params = Enum.into(params, %{})

    {:ok, pending_withdrawal} =
      %Payouts.PendingWithdrawals.PendingWithdrawal{}
      |> Ecto.Changeset.change(%{
        patient_id: params.patient_id,
        record_id: params.record_id,
        visit_id: params[:visit_id],
        specialist_id: params.specialist_id,
        amount: params.amount,
        inserted_at: params[:inserted_at]
      })
      |> Postgres.Repo.insert()

    pending_withdrawal
  end
end
